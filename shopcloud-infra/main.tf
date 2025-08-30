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

# Docker Network
resource "docker_network" "kafka_network" {
  name = "kafka_network"
}

# PostgreSQL Resources
resource "docker_image" "postgres_image" {
  name = "postgres:15-alpine"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres_image.image_id
  networks_advanced {
    name = docker_network.kafka_network.name
  }
  ports {
    internal = 5432
    external = 5432
  }
  env = [
    "POSTGRES_DB=shopcloud",
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_HOST_AUTH_METHOD=trust"
  ]
  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "/tmp/postgres-data" # You might want to use a proper volume
  }
}

# Kafka Resources
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

# Kubernetes Base Resources
resource "kubernetes_namespace" "test" {
  metadata {
    name = "shopcloud"
  }
}

# ArgoCD Resources
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  version    = "5.53.0"
  wait       = true
  wait_for_jobs = false

  # Add configuration for HTTP access
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.ingress.enabled"
    value = "false" # We'll create our own ingress
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
}

resource "null_resource" "crd_wait" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = "powershell -Command \"Start-Sleep -Seconds 90\"" # Increased sleep time
  }
}

# ArgoCD Ingress with proper configuration
resource "kubernetes_ingress_v1" "argocd_ingress" {
  depends_on = [null_resource.crd_wait]

  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "nginx.ingress.kubernetes.io/rewrite-target"   = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"     = "false"
    }
  }

  spec {
    ingress_class_name = "nginx" # Add ingress class

    rule {
      host = "argocd.info"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Hello World Resources
resource "kubernetes_deployment" "hello_world" {
  metadata {
    name = "web"
    labels = {
      app = "web"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "web"
      }
    }
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
        container {
          name  = "hello-app"
          image = "gcr.io/google-samples/hello-app:1.0"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hello_world" {
  metadata {
    name = "web"
  }
  spec {
    selector = {
      app = "web"
    }
    port {
      port        = 8080
      target_port = 8080
    }
    type = "NodePort"
  }
}

/*resource "kubernetes_ingress_v1" "hello_world_ingress" {
  metadata {
    name = "hello-world-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target": "/"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "hello-world.info"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "web"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}*/

# Variables
variable "github_repo_url" {
  description = "GitHub repository URL for ArgoCD application"
  type        = string
  default     = "https://github.com/4arturas/shopcloud.git"
}

variable "target_namespace" {
  description = "Target namespace for ArgoCD application"
  type        = string
  default     = "shopcloud"
}

# Output PostgreSQL connection details
output "postgres_connection" {
  value = {
    host     = "localhost"
    port     = 5432
    database = "shopcloud"
    username = "postgres"
    password = "postgres"
  }
  description = "PostgreSQL connection details"
}