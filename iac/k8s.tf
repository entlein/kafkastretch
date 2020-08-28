resource "azurerm_resource_group" "rg-k8s" {
  name     =  var.globals.resource_group_name
  location =  var.globals.location
}

# networks

resource "azurerm_virtual_network" "acctvnet" {
  name                = "acctvnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.globals.location
  resource_group_name = azurerm_resource_group.rg-k8s.name
}

resource "azurerm_virtual_network" "acctvnetalt" {
  name                = "acctvnetalt"
  address_space       = ["10.2.0.0/16"]
  location            = var.globals.location_alt
  resource_group_name = azurerm_resource_group.rg-k8s.name
}

# VNET peering 

resource "azurerm_virtual_network_peering" "acctvnet" {
  name                      = "acctvnet_to_acctvnetalt"
  resource_group_name       = azurerm_resource_group.rg-k8s.name
  virtual_network_name      = azurerm_virtual_network.acctvnet.name
  remote_virtual_network_id = azurerm_virtual_network.acctvnetalt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}

resource "azurerm_virtual_network_peering" "acctvnetalt" {
  name                      = "acctvnetalt_to_acctvnet"
  resource_group_name       = azurerm_resource_group.rg-k8s.name
  virtual_network_name      = azurerm_virtual_network.acctvnetalt.name
  remote_virtual_network_id = azurerm_virtual_network.acctvnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

}

# subnets
resource "azurerm_subnet" "snet_pink" {
  name                 = "snet_pink"
  resource_group_name = azurerm_resource_group.rg-k8s.name
  virtual_network_name = "acctvnetalt"
  depends_on           = [ azurerm_virtual_network.acctvnetalt ]
  address_prefix       = "10.2.1.0/24"
  #virtual_network_name = "acctvnet"
  #depends_on           = [ azurerm_virtual_network.acctvnet ]
  #address_prefix       = "10.1.4.0/24"
}

resource "azurerm_subnet" "snet_purple" {
  name                 = "snet_purple"
  resource_group_name = azurerm_resource_group.rg-k8s.name
  virtual_network_name = "acctvnetalt"
  depends_on           = [ azurerm_virtual_network.acctvnetalt ]
  address_prefix       = "10.2.2.0/24"
  #virtual_network_name = "acctvnet"
  #depends_on           = [ azurerm_virtual_network.acctvnet ]
  #address_prefix       = "10.1.5.0/24"
}

resource "azurerm_subnet" "snet_zk" {
  name                 = "snet_zk"
  resource_group_name  = azurerm_resource_group.rg-k8s.name
  virtual_network_name = "acctvnet"
  depends_on           = [ azurerm_virtual_network.acctvnet ]
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_subnet" "snet_yellow" {
  name                 = "snet_yellow"
  resource_group_name = azurerm_resource_group.rg-k8s.name
  virtual_network_name = "acctvnet"
  depends_on           = [ azurerm_virtual_network.acctvnet ]
  address_prefix       = "10.1.2.0/24"
}

resource "azurerm_subnet" "snet_orange" {
  name                 = "snet_orange"
  resource_group_name = azurerm_resource_group.rg-k8s.name
  virtual_network_name = "acctvnet"
  depends_on           = [ azurerm_virtual_network.acctvnet ]
  address_prefix       = "10.1.3.0/24"
}

# ZK
resource "azurerm_kubernetes_cluster" "akszk" {
    depends_on          = [ azurerm_subnet.snet_zk ]
    name                = var.kafka-zk.cluster_name
    location            = azurerm_resource_group.rg-k8s.location
    resource_group_name = azurerm_resource_group.rg-k8s.name
    dns_prefix          = var.kafka-zk.dns_prefix
    kubernetes_version  = "1.15.5"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq0cuN7gvIMWoL1jT5nDzeG7NVaVd3PaFsA+D84tH51hyq8jMXp7AV5vOe+cEt4KVdsnmA9f9oRv72uJbEZX6keMdxy+1Adn6qqFfPemLkooI2jlv8T4ksuZL4+T3lWA1P1i5px4+ZLLDjVAj1o/fECi8/95xJuhWg9PykaNEQOz22a4pWIjGFMAy60GoBEMlc5YeAjIhNvEx1tHh82V6omuj3UIxXSr6ssGuE2bi1h6qmFoxoiTPnpHXJULL2LFZH7SCLQDCMYoGZvld/rQckRYjM7hJrnsfv/kmEHiEWWXxGsayO4NmL6jMWLpMVteJuV1t1Lo9UgRqre0QMLMeb futik@Lukass-MacBook-Pro.local"
        }
    }
    

    default_node_pool {
        name            = "default"
        node_count      = var.kafka-zk.agent_count
        vm_size         = "Standard_DS1_v2"
        vnet_subnet_id  = azurerm_subnet.snet_zk.id
        #type            = "AvailabilitySet"
        os_disk_size_gb = "50"
        
    }

    service_principal {
        client_id     = var.globals.client_id
        client_secret = var.globals.client_secret
    }

    tags = {
        layer = var.globals.layer
        color = var.kafka-zk.color
    }

    network_profile {
        network_plugin     = "azure"
        load_balancer_sku   = "standard"

        # service_cidr       = var.globals.aks_service_cidr
    }
}

# YELLOW
resource "azurerm_kubernetes_cluster" "aksyellow" {
    depends_on          = [ azurerm_subnet.snet_yellow ]
    name                = var.kafka-yellow.cluster_name
    location            = azurerm_resource_group.rg-k8s.location
    resource_group_name = azurerm_resource_group.rg-k8s.name
    dns_prefix          = var.kafka-yellow.dns_prefix
    kubernetes_version  = "1.15.5"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = var.sshpubkey
        }
    }
    

    default_node_pool {
        name            = "default"
        node_count      = var.kafka-yellow.agent_count
        vm_size         = "Standard_DS1_v2"
        vnet_subnet_id  = azurerm_subnet.snet_yellow.id
        
    }

    service_principal {
        client_id     = var.globals.client_id
        client_secret = var.globals.client_secret
    }

    tags = {
        layer = var.globals.layer
        color = var.kafka-yellow.color
    }

    network_profile {
        network_plugin     = "azure"
        load_balancer_sku   = "standard"
        # service_cidr       = var.globals.aks_service_cidr
    }
}

# ORANGE
resource "azurerm_kubernetes_cluster" "aksorange" {
    depends_on          = [ azurerm_subnet.snet_orange ]
    name                = var.kafka-orange.cluster_name
    location            = azurerm_resource_group.rg-k8s.location
    resource_group_name = azurerm_resource_group.rg-k8s.name
    dns_prefix          = var.kafka-yellow.dns_prefix
    kubernetes_version  = "1.15.5"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = var.sshpubkey
        }
    }
    

    default_node_pool {
        name            = "default"
        node_count      = var.kafka-orange.agent_count
        vm_size         = "Standard_DS1_v2"
        vnet_subnet_id  = azurerm_subnet.snet_orange.id
        
    }

    service_principal {
        client_id     = var.globals.client_id
        client_secret = var.globals.client_secret
    }

    tags = {
        layer = var.globals.layer
        color = var.kafka-orange.color
    }

    network_profile {
        network_plugin     = "azure"
        load_balancer_sku   = "standard"
        # service_cidr       = var.globals.aks_service_cidr
    }
}

# PINK
resource "azurerm_kubernetes_cluster" "akspink" {
    depends_on          = [ azurerm_subnet.snet_pink ]
    name                = var.kafka-pink.cluster_name
    location            = var.globals.location_alt
    #location            = var.globals.location
    resource_group_name = azurerm_resource_group.rg-k8s.name
    dns_prefix          = var.kafka-pink.dns_prefix
    kubernetes_version  = "1.15.5"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = var.sshpubkey
        }
    }
    
    default_node_pool {
        name            = "default"
        node_count      = var.kafka-pink.agent_count
        vm_size         = "Standard_DS1_v2"
        vnet_subnet_id  = azurerm_subnet.snet_pink.id
        #type            = "AvailabilitySet"
        #os_disk_size_gb = "50"
        
    }

    service_principal {
        client_id     = var.globals.client_id
        client_secret = var.globals.client_secret
    }

    tags = {
        layer = var.globals.layer
        color = var.kafka-pink.color
    }

    network_profile {
        network_plugin     = "azure"
        load_balancer_sku   = "standard"
        # service_cidr       = var.globals.aks_service_cidr
    }
}


# PURPLE
resource "azurerm_kubernetes_cluster" "akspurple" {
    depends_on          = [ azurerm_subnet.snet_purple ]
    name                = var.kafka-purple.cluster_name
    location            = var.globals.location_alt
    #location            = var.globals.location
    resource_group_name = azurerm_resource_group.rg-k8s.name
    dns_prefix          = var.kafka-purple.dns_prefix
    kubernetes_version  = "1.15.5"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = var.sshpubkey
        }
    }
    

    default_node_pool {
        name            = "default"
        node_count      = var.kafka-purple.agent_count
        vm_size         = "Standard_DS1_v2"
        vnet_subnet_id  = azurerm_subnet.snet_purple.id
        #type            = "AvailabilitySet"
        #os_disk_size_gb = "50"
        
    }

    service_principal {
        client_id     = var.globals.client_id
        client_secret = var.globals.client_secret
    }

    tags = {
        layer = var.globals.layer
        color = var.kafka-purple.color
    }

    network_profile {
        network_plugin     = "azure"
        load_balancer_sku   = "standard"
        # service_cidr       = var.globals.aks_service_cidr
    }
}