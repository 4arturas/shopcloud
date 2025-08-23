terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.5.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "docker" {}

module "kafka" {
  source = "./modules/kafka"
}

module "kubernetes_base" {
  source = "./modules/kubernetes-base"
}

module "argocd" {
  source = "./modules/argocd"
  github_repo_url = var.github_repo_url
  target_namespace = module.kubernetes_base.namespace_name
}

module "spring_boot_apps" {
  source = "./modules/spring-boot-apps"
  target_namespace = module.kubernetes_base.namespace_name
  config_server_image = "cloud-config-server:0.0.1-SNAPSHOT"
  hello_service_image = "cloud-hello-service:0.0.1-SNAPSHOT"
}