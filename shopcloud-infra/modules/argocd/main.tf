resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.3.0"

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
      name       = "shopcloud-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.github_repo_url
        targetRevision = "HEAD"
        path           = "shopcloud-infra"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.target_namespace
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