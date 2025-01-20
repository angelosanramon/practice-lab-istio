resource "helm_release" "kubernetes_gateway_api_crds" {
  count            = var.istio_mesh_mode == "ambient" ? 1 : 0
  name             = "kubernetes-gateway-api-crds"
  repository       = "https://charts.portefaix.xyz"
  chart            = "gateway-api-crds"
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
  timeout          = 1800
}

resource "helm_release" "istiod" {
  name             = "istio-control-plane"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
  values           = [ file("./helm/istio/istiod_values.yaml") ]
  timeout          = 1800

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  dynamic "set" {
    for_each = var.istio_mesh_mode == "ambient" ? ["ambient"] : []
    content {
      name  = "profile"
      value = set.value
    }
  }

  depends_on = [ helm_release.istio_base ]
}

resource "helm_release" "istio_cni" {
  count            = var.istio_mesh_mode == "ambient" ? 1 : 0
  name             = "istio-cni"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "cni"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
  timeout          = 1800

  set {
    name  = "profile"
    value = "ambient"
  }

  # Minikube specific setting
  set {
    name  = "global.platform"
    value = "minikube"
  }

  set {
    name  = "ambient.ipv6"
    value = false
  }
}

resource "helm_release" "istio_ztunnel" {
  count            = var.istio_mesh_mode == "ambient" ? 1 : 0
  name             = "istio-ztunnel"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "ztunnel"
  namespace        = var.istio_namespace
  create_namespace = true
  version          = var.istio_helm_chart_version
  timeout          = 1800
}

resource "helm_release" "istio_ingressgateway" {
  count            = var.istio_mesh_mode == "sidecar" ? 1 : 0
  name             = "istio-ingressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = var.istio_helm_chart_version
  timeout          = 1800

  depends_on = [
    helm_release.istio_base, 
    helm_release.istiod
  ]
}

resource "helm_release" "istio_egressgateway" {
  count            = var.istio_mesh_mode == "sidecar" ? 1 : 0
  name             = "istio-egressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-egress"
  create_namespace = true
  version          = var.istio_helm_chart_version
  values = [ file("./helm/istio/egress_gateway_values.yaml") ]
  timeout          = 1800

  depends_on = [
    helm_release.istio_base, 
    helm_release.istiod
  ]
}
