resource "kubernetes_namespace" "kyverno" {
  metadata {
    name = "kyverno"
  }
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = kubernetes_namespace.kyverno.metadata[0].name
  version    = "3.1.4"

  # Wait for CRDs
  skip_crds = false
}

resource "helm_release" "kyverno_policies" {
  name       = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  namespace  = kubernetes_namespace.kyverno.metadata[0].name
  version    = "3.0.6"
  
  depends_on = [helm_release.kyverno]
}
