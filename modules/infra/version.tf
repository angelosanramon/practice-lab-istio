terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"
    }

    kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">=2.33.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.16.0"
    }

    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.0.0"
    }
  }
}
