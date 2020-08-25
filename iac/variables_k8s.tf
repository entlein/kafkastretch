variable "kafka-orange" {
    type = map

    default = { 
        agent_count = 2
        dns_prefix = "aksorange"
        cluster_name = "aksorange"
        color = "orange"
        subnet_id = "/subscriptions/$(subscriptionID)/resourceGroups/rg-kafka/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/snet_orange" 
    }
  
}

variable "kafka-yellow" {
    type = map

    default = { 
        agent_count = 2
        dns_prefix = "aksyellow"
        cluster_name = "aksyellow"
        color = "yellow"
        subnet_id = "/subscriptions/$(subscriptionID)/resourceGroups/rg-kafka/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/snet_yellow" 
    }
  
}

variable "kafka-pink" {
    type = map

    default = { 
        agent_count = 2
        dns_prefix = "akspink"
        cluster_name = "akspink"
        color = "pink"
        subnet_id = "/subscriptions/$(subscriptionID)/resourceGroups/rg-kafka/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/snet_pink" 
    }
  
}

variable "kafka-purple" {
    type = map

    default = { 
        agent_count = 2
        dns_prefix = "akspurple"
        cluster_name = "akspurple"
        color = "purple"
        subnet_id = "/subscriptions/$(subscriptionID)/resourceGroups/rg-kafka/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/snet_purple" 
    }
  
}

variable "kafka-zk" {
    type = map

    default = { 
        agent_count = 2
        dns_prefix = "akszk"
        cluster_name = "akszk"
        color = "blue"
        subnet_id = "/subscriptions/$(subscriptionID)/resourceGroups/rg-kafka/providers/Microsoft.Network/virtualNetworks/acctvnet/subnets/snet_zk" 
    }
  
}

variable "globals" {
    type = map

    default = { 
        client_id = ""
        client_secret = ""
        resource_group_name = "rg-kafka"
        location = "East US 2"
        location_alt = "West US 2"
        layer = "orchestrator"
        aks_service_cidr = "10.1.0.0/16"
    }
}