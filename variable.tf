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

variable "grafana_admin_username" {
  description = "Username for the Grafana admin."
  default     = "grafana-admin"
}

variable "grafana_admin_password" {
  description = "Password for the Grafana admin"
  sensitive   = true
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
