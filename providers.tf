
terraform {
  required_version = ">=0.14.5"
  backend "azurerm" {
    # resource_group_name  = "winkstgrg"
    # storage_account_name = "winkteststg2"
    # container_name       = "winkcontainer"
    # key                  = "mytest123.tfstate"
    # #access_key           = "adWGcVYcGkD+ETXABhMRo5VXOeG2Bti3zVRu3lqJhTboUoaIr3l8rkkdggA3Nna1CAFzF1kueRfr+AStoRIvhA=="
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.75.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    local = {
      source = "hashicorp/local"
    }


  }
}

provider "dns" {
  update {
    server = "108.158.221.89"
  }
}

provider "azurerm" {
  subscription_id = "3e3f5f63-438b-4205-b50e-df27fa676994"
  features {}
}
provider "azurerm" {
  alias = "second"
  subscription_id = "d34f5d04-d7e0-49c3-8377-f92ece5485d7"
  features {}
}

