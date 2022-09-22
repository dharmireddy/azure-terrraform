output "public_ip" {
  value = azurerm_public_ip.myVm1PublicIP.ip_address
}