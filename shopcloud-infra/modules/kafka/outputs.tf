output "kafka_network_name" {
  description = "The name of the Docker network created for Kafka."
  value       = docker_network.kafka_network.name
}