# Network Module - Main Configuration

# Define the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.label_prefix}-Vnet"
  address_space       = ["10.0.0.0/14"]
  location            = var.region
  resource_group_name = var.resource_group_name
}

# Define subnets for different environments
resource "azurerm_subnet" "prod" {
  name                 = "${var.label_prefix}-Subnet-Prod"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "${var.label_prefix}-Subnet-Test"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "dev" {
  name                 = "${var.label_prefix}-Subnet-Dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "admin" {
  name                 = "${var.label_prefix}-Subnet-Admin"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.3.0.0/16"]
}

# Define network security group and rules
resource "azurerm_network_security_group" "webserver" {
  name                = "${var.label_prefix}-SG"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Define network interface (without public IP)
resource "azurerm_network_interface" "webserver" {
  name                = "${var.label_prefix}-Nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.label_prefix}-NicConfig"
    subnet_id                     = azurerm_subnet.prod.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Link the security group to the NIC
resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
} 