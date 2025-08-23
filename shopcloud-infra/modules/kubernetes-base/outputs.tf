output "namespace_name" {
  description = "The name of the Kubernetes namespace."
  value       = kubernetes_namespace.test.metadata[0].name
}