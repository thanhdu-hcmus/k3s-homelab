terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "kubernetes" {
  config_path = "k3s.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "k3s.yaml"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_namespace" "environments" {
  for_each = toset(["dev", "staging", "prod"])
  metadata {
    name = "env-${each.key}"
  }
}
