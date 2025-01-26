locals {
  jenkins_istio_ambient_mode_labels = {
    "istio.io/dataplane-mode" = "ambient"
  }

  jenkins_istio_sidecar_mode_labels = {
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name   = var.jenkins_namespace

    labels = var.istio_mesh_mode == "ambient" ? local.jenkins_istio_ambient_mode_labels : local.jenkins_istio_sidecar_mode_labels
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = var.jenkins_namespace
  version          = var.jenkins_helm_chart_version
  values           = [file("./helm/jenkins/values.yaml")]
  timeout          = 3600

  set {
    name  = "controller.admin.username"
    value = var.jenkins_admin_user
  }

  set {
    name  = "controller.admin.password"
    value = var.jenkins_admin_password
  }

  depends_on = [ kubernetes_namespace.jenkins ]
}

resource "helm_release" "jenkins_istio_policies" {
  name      = "jenkins-istio-policies"
  chart     = "./helm/istio-policies"
  namespace = var.jenkins_namespace
  values    = [
    file( var.istio_mesh_mode == "ambient" ? "./helm/jenkins/ambient_istio_policies_values.yaml" : "./helm/jenkins/sidecar_istio_policies_values.yaml" )
  ]

  depends_on = [ helm_release.jenkins ]
}
