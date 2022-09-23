provider   "azurerm"   { 
   version   =   "= 2.0.0" 
   features   {} 
 } 

 resource   "azurerm_resource_group"   "rg"   { 
   name   =   "my-first-terraform-rg" 
   location   =   "northeurope" 
 } 

 resource   "azurerm_virtual_network"   "myvnet"   { 
   name   =   "my-vnet" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   "frontendSubnet" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.myvnet.name 
   address_prefix   =   "10.0.1.0/24" 
 } 

 resource   "azurerm_public_ip"   "myvm1publicip"   { 
   name   =   "MyPublicIP21" 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 

 resource   "azurerm_network_interface"   "myvm1nic"   { 
   name   =   "myvm1-nic" 
   location   =   "northeurope" 
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.myvm1publicip.id 
   } 
 } 

 resource "azurerm_network_security_group" "nsg" {
  name                = "ssh_nsg"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "RDP"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.myvm1nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
 resource   "azurerm_windows_virtual_machine"   "MyVirtualMachine1"   { 
   name                    =   "myvm1"   
   location                =   "northeurope" 
   resource_group_name     =   azurerm_resource_group.rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvm1nic.id ] 
   size                    =   "Standard_B1s" 
   admin_username          =   "adminuser" 
   admin_password          =   "Password123!" 

   source_image_reference   { 
     publisher   =   "MicrosoftWindowsServer" 
     offer       =   "WindowsServer" 
     sku         =   "2019-Datacenter" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching             =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 }

# resource "azurerm_linux_virtual_machine" "linuxVirtualMachine" {
 # name                = "example-machine"
 # resource_group_name = azurerm_resource_group.rg.name
 # location            = "northeurope"
 # size                = "Standard_B1s"
  #admin_username      = "adminuser"
  #admin_password          =   "Password123!"


 # network_interface_ids = [
 #   azurerm_network_interface.myvm1nic.id,
 #]

 # os_disk {
 #   caching              = "ReadWrite"
 #   storage_account_type = "Standard_LRS"
 # }
  
  