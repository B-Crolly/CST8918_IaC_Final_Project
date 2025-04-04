# Define the resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-RG"
  location = var.region
}

# Define a public IP address
resource "azurerm_public_ip" "webserver" {
  name                = "${var.labelPrefix}-PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Define the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.labelPrefix}-Vnet"
  address_space       = ["10.0.0.0/14"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Define subnets for different environments
resource "azurerm_subnet" "prod" {
  name                 = "${var.labelPrefix}-Subnet-Prod"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "${var.labelPrefix}-Subnet-Test"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "dev" {
  name                 = "${var.labelPrefix}-Subnet-Dev"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "admin" {
  name                 = "${var.labelPrefix}-Subnet-Admin"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.3.0.0/16"]
}

# Define network security group and rules
resource "azurerm_network_security_group" "webserver" {
  name                = "${var.labelPrefix}-SG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

# Define the network interface
resource "azurerm_network_interface" "webserver" {
  name                = "${var.labelPrefix}-Nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.labelPrefix}-NicConfig"
    subnet_id                     = azurerm_subnet.prod.id
    private_ip_address_allocation = "Static"
    private_ip_address           = "10.0.1.10"
    public_ip_address_id          = azurerm_public_ip.webserver.id
  }
  # This is to ensure that the ip address is disassociated from the NIC before it is deleted
  lifecycle {
    create_before_destroy = true
  }
}

# Link the security group to the NIC
resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

