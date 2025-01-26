variable "istio_mesh_mode" {
  description = "Istio data plane mode."
  default     = "ambient"

  validation {
    condition = var.istio_mesh_mode == "sidecar" || var.istio_mesh_mode == "ambient"
    error_message = "Istio data plane mode must either be sidecar or ambient."
  }
}

variable "istio_namespace" {
  description = "Namespace to install Istio."
  default     = "istio-system"
}

variable "istio_helm_chart_version" {
  description = "Istio helm chart version."
  default     = "1.24.2"
}

variable "kiali_namespace" {
  description = "Nameespace to install Kialie."
  default     = "kiali"
}

variable "kiali_helm_chart_version" {
  description = "Kiali helm chart version."
  default     = "2.2.0"
}

variable "prometheus_namespace" {
  description = "Namespace to install Prometheus."
  default     = "prometheus"
}

variable "prometheus_helm_chart_version" {
  description = "Prometheus helm chart version."
  default     = "26.0.1"
}

variable "prometheus_blackbox_exporter_helm_chart_version" {
  description = "Prometheus blackbox exporter helm chart version."
  default     = "9.1.0"
}

variable "prometheus_operator_crds_helm_chart_version" {
  description = "Prometheus operator crds helm chart version."
  default     = "17.0.2"
}

variable "argocd_namespace" {
  description = "Namespace to install ArgoCD."
  default     = "argocd"
}

variable "argocd_helm_chart_version" {
  description = "ArgoCD helm chart version."
  default     = "7.7.9"  
}

variable "grafana_namespace" {
  description = "Namespace to install Grafana."
  default     = "grafana"
}

variable "grafana_helm_chart_version" {
  description = "Grafana Helm chart version."
  default     = "8.6.4"
}

variable "grafana_admin_user" {
  description = "Admin user for Grafana."
  default     = "grafana-admin"
}

variable "grafana_admin_password" {
  description = "Password for Grafana admin user."
  default     = ""
}

variable "jaeger_namespace" {
  description = "Namespace to install Jaeger."
  default     = "jaeger"
}

variable "jaeger_helm_chart_version" {
  description = "Jaeger Helm chart version."
  default     = "3.3.3"
}

variable "bookinfo_namespace" {
  description = "Namespace to install Bookinfo"
  default     = "bookinfo"
}

variable "bookinfo_helm_chart_version" {
  description = "Bookinfo Helm chart version."
  default     = "0.1.0"
}

variable "cert_manager_namespace" {
  description = "Namespace to install cert-manager."
  default     = "cert-manager"
}

variable "cert_manager_helm_chart_version" {
  description = "Cert manager helm chart version."
  default = "1.16.3"
}

variable "reflector_namespace" {
  description = "Namespace to install Kubernetes Reflector."
  default     = "reflector"
}

variable "reflector_helm_chart_version" {
  description = "Kubernetes Reflector helm chart version."
  default = "7.1.288"
}

variable "keycloak_namespace" {
  description = "Namespace to install Keycloak."
  default     = "keycloak"
}

variable "keycloak_helm_chart_version" {
  description = "Keycloak helm chart version."
  default     = "18.9.0"
}

variable "keycloak_admin_user" {
  description = "Keycloak admin username."
  default     = "kc-admin"
}

variable "keycloak_admin_password" {
  description = "Keycloak admin password."
  default     = ""
}

variable "vault_namespace" {
  description = "Namespace to install Vault."
  default     = "vault"
}

variable "vault_helm_chart_version" {
  description = "Vault helm chart version."
  default     = "0.29.1"
}

variable "vault_unseal_keys_reader_user" {
  description = "User that will be used to read unseal keys in Vault."
  default     = "unsealkeysreader"
}

variable "vault_unseal_keys_reader_password" {
  description = "Password for the unseal keys reader user."
  default     = ""
}

variable "jenkins_namespace" {
  description = "Namespace to install Jenkins."
  default     = "jenkins"
}

variable "jenkins_helm_chart_version" {
  description = "Jenkins helm chart version."
  default     = "5.8.5"
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username."
  default     = "jenkins-admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password."
  default     = ""
}