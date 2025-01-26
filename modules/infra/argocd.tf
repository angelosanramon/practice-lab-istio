locals {
  argocd_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  argocd_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name   = var.argocd_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.argocd_istio_ambient_mode_labels : local.argocd_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.7.5"
  values           = [ file("./helm/argocd/values.yaml") ]
  timeout          = 3600

  depends_on = [ kubernetes_namespace.argocd ]
}

resource "helm_release" "argocd_istio_policies" {
  name      = "argocd-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = kubernetes_namespace.argocd.id
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/argocd/ambient_istio_policies_values.yaml" : "./helm/argocd/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.argocd ]
}
