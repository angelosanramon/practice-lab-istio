resource "kubernetes_namespace" "argocd" {
  metadata {
    name   = var.argocd_namespace

    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.istio_ingressgateway
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.7.5"
  values           = [ file("./helm/argocd/values.yaml") ]

  depends_on = [ kubernetes_namespace.argocd ]
}

resource "helm_release" "argocd_istio_policies" {
  name      = "argocd-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.argocd.id
  values    = [ file("./helm/argocd/istiao_policies_values.yaml") ]

  depends_on = [ helm_release.argocd ]
}
