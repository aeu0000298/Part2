resource "azurerm_subnet" "default" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "Subnet-Jie"
  resource_group_name  = "JieIAC-rg"
  virtual_network_name = "JieIAC-vnet"
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "default" {
  name                = "JieIAC.mysql.database.azure.com"
  resource_group_name = "JieIAC-rg"
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "mysqlfsVnetZoneJieIAC.com"
  private_dns_zone_name = "JieIAC.mysql.database.azure.com"
  resource_group_name   = "JieIAC-rg"
  virtual_network_id    = "/subscriptions/628c474b-63de-457c-a85b-b64ed370269d/resourceGroups/JieIAC-rg/providers/Microsoft.Network/virtualNetworks/JieIAC-vnet"
  depends_on = [azurerm_private_dns_zone.default]
}

resource "azurerm_mysql_flexible_database" "default" {
  name                = "Jie-mysqlfs-iac601"
  resource_group_name = "JieIAC-rg"
  server_name         = azurerm_mysql_flexible_server.default.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
  depends_on = [ azurerm_mysql_flexible_server.default ]
}


# Manages the MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "default" {
  location                     = "AustraliaEast"
  name                         = "jie-mysqlfs-iac601"
  resource_group_name          = "JieIAC-rg"
  administrator_login          = "azureuser"
  administrator_password       = "Aspire2International@91"
  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.default.id
  geo_redundant_backup_enabled = false
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  sku_name                     = "GP_Standard_D2ds_v4"
  version                      = "8.0.21"
  zone                         = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}
