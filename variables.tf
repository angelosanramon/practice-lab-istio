variable "istio_mesh_mode" {
  description = "Istio data plane mode."
  default     = "ambient"

  validation {
    condition = var.istio_mesh_mode == "sidecar" || var.istio_mesh_mode == "ambient"
    error_message = "Istio data plane mode must either be sidecar or ambient."
  }
}