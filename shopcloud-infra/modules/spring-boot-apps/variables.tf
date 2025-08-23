variable "target_namespace" {
  description = "The namespace to deploy the applications to."
  type        = string
}

variable "config_server_image" {
  description = "The Docker image for the config-server."
  type        = string
}

variable "hello_service_image" {
  description = "The Docker image for the hello-service."
  type        = string
}
