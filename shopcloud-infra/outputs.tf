output "kafka_network_name" {
  description = "The name of the Docker network created for Kafka."
  value       = module.kafka.kafka_network_name
}

output "kubernetes_namespace" {
  description = "The name of the Kubernetes namespace."
  value       = module.kubernetes_base.namespace_name
}