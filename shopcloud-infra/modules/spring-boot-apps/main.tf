resource "kubernetes_deployment" "config_server_deployment" {
  metadata {
    name = "config-server"
    namespace = "${var.target_namespace}"
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
    namespace = "${var.target_namespace}"
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
    namespace = "${var.target_namespace}"
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
          image = var.hello_service_image
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
    namespace = "${var.target_namespace}"
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
