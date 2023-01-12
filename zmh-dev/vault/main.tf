terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.11.0"
    }
  }
}

provider "vault" {
  # Configuration options
}

provider "kubernetes" {
  # Configuration options
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "http://example.com:443"
  kubernetes_ca_cert     = "-----BEGIN CERTIFICATE-----\nexample\n-----END CERTIFICATE-----"
  token_reviewer_jwt     = "ZXhhbXBsZQo="
  issuer                 = "api"
  disable_iss_validation = "true"
}
