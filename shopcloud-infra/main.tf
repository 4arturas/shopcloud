
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

resource "docker_network" "kafka_network" {
  name = "kafka_network"
}

resource "docker_image" "zookeeper_image" {
  name = "confluentinc/cp-zookeeper:latest"
}

resource "docker_container" "zookeeper" {
  name  = "zookeeper"
  image = docker_image.zookeeper_image.image_id
  networks_advanced {
    name = docker_network.kafka_network.name
  }
  ports {
    internal = 2181
    external = 2181
  }
  env = [
    "ZOOKEEPER_CLIENT_PORT=2181",
    "ZOOKEEPER_TICK_TIME=2000"
  ]
}

resource "docker_image" "kafka_image" {
  name = "confluentinc/cp-kafka:latest"
}

resource "docker_container" "kafka" {
  name  = "kafka"
  image = docker_image.kafka_image.image_id
  networks_advanced {
    name = docker_network.kafka_network.name
  }
  ports {
    internal = 9092
    external = 9092
  }
  env = [
    "KAFKA_BROKER_ID=1",
    "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181",
    "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1"
  ]
  depends_on = [docker_container.zookeeper]
}







resource "kubernetes_deployment" "config_server_deployment" {
  metadata {
    name = "config-server"
    namespace = "shopcloud"
  }
  spec {
    selector {
      match_labels = {
        app = "config-server"
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          app = "config-server"
        }
      }
      spec {
        container {
          name  = "config-server"
          image = "cloud-config-server:0.0.1-SNAPSHOT"
          port {
            container_port = 8888
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "config_server_service" {
  metadata {
    name = "config-server"
    namespace = "shopcloud"
  }
  spec {
    selector = {
      app = "config-server"
    }
    port {
      port        = 8888
      target_port = 8888
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "hello_service_deployment" {
  metadata {
    name = "hello-service"
    namespace = "shopcloud"
  }
  spec {
    selector {
      match_labels = {
        app = "hello-service"
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          app = "hello-service"
        }
      }
      spec {
        container {
          name  = "hello-service"
          image = "cloud-hello-service:0.0.1-SNAPSHOT"
          port {
            container_port = 8080
          }
          env {
            name = "SPRING_CLOUD_CONFIG_URI"
            value = "http://config-server:8888"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello_service_service" {
  metadata {
    name = "hello-service"
    namespace = "shopcloud"
  }
  spec {
    selector = {
      app = "hello-service"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
  }
}





resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.3.0" # Using the version from the fragment

  namespace = "argocd"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
}

resource "kubernetes_manifest" "shopcloud_argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "shopcloud-app"
      namespace = "argocd" # ArgoCD applications are typically defined in the argocd namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/4arturas/shopcloud.git"
        targetRevision = "HEAD"
        path           = "shopcloud-infra"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "shopcloud"
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "shopcloud"
  }
}
