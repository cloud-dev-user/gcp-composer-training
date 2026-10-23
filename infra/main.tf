provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "composer_api" {
  provider = google-beta
  project = var.project_id
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
  // this flag is introduced in 5.39.0 version of Terraform. If set to true it will
  //prevent you from disabling composer_api through Terraform if any environment was
  //there in the last 30 days
  check_if_service_has_usage_on_destroy = true
}

resource "google_service_account" "custom_service_account" {
  provider = google-beta
  account_id   = "custom-service-account"
  display_name = "Example Custom Service Account"
}

resource "google_project_iam_member" "custom_service_account" {
  provider = google-beta
  project  = var.project_id
  member   = format("serviceAccount:%s", google_service_account.custom_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.worker"
}

resource "google_service_account_iam_member" "custom_service_account" {
  provider = google-beta
  service_account_id = google_service_account.custom_service_account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_composer_environment" "example_environment" {
  depends_on = [google_project_service.composer_api, google_service_account_iam_member.custom_service_account]
  provider = google-beta
  name   = var.environment_name
  region = var.region

  config {

    software_config {
      image_version = "composer-2.12.1-airflow-2.10.2"
    }

    node_config {
      service_account = google_service_account.custom_service_account.email
    }

  }
}
