variable "TELE_TOKEN" {
  type        = string
  description = "TELE_TOKEN"
}

variable "GOOGLE_PROJECT" {
  type        = string
  description = "GOOGLE_PROJECT"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = 2
  description = "GKE nodes number"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "us-central1-c"
  description = "GOOGLE_REGION"
}

variable "GITHUB_OWNER" {
  type        = string
  description = "The GitHub owner"
}

variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub personal access token"
}

variable "FLUX_GITHUB_REPO" {
  type        = string
  default     = "flux-gitops"
  description = "Flux gitops repository"
}

variable "FLUX_GITHUB_TARGET_PATH" {
  type        = string
  default     = "clusters"
  description = "Flux manifests subdirectory"
}
