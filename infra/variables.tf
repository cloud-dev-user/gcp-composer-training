variable "project_id" {
  description = "GCP project ID where the Composer environment is created"
  type        = string
}

variable "project_number" {
  description = "GCP project number, used to name the Composer service agent"
  type        = string
}

variable "region" {
  description = "Region for the Composer environment"
  type        = string
  default     = "us-central1"
}

variable "environment_name" {
  description = "Name of the Composer environment"
  type        = string
  default     = "composer-training"
}
