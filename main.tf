resource "google_storage_bucket" "functions_store" {
  name     = "${var.bucketname}"
  project  = "${var.project}"
  location = "${var.region}"
}

data "archive_file" "function_suspend_func" {
  type        = "zip"
  source_dir  = "./suspend_func"
  output_path = "suspend_func.zip"
}

data "archive_file" "function_resume_func" {
  type        = "zip"
  source_dir  = "./resume_func"
  output_path = "resume_func.zip"
}

resource "google_storage_bucket_object" "resume_function_code" {
  name   = "resume_func.zip"
  bucket = "${google_storage_bucket.functions_store.name}"
  source = "${data.archive_file.function_resume_func.output_path}"
}

resource "google_storage_bucket_object" "suspend_function_code" {
  name   = "suspend_func.zip"
  bucket = "${google_storage_bucket.functions_store.name}"
  source = "${data.archive_file.function_suspend_func.output_path}"
}


# google_cloudfunctions_function.resume_func:
resource "google_cloudfunctions_function" "resume_func" {
    available_memory_mb          = 256
    docker_registry              = "CONTAINER_REGISTRY"
    entry_point                  = "arr_resume_func"
    https_trigger_security_level = "SECURE_OPTIONAL"
    https_trigger_url            = "https://${var.region}-${var.project}.cloudfunctions.net/resume_func"
    ingress_settings             = "ALLOW_ALL"
    labels                       = {
        "deployment-tool" = "console-cloud"
    }
    environment_variables = {
      "PROJECT_ID" = "${var.project}"
      "SERVICE_ACCOUNT"="${var.service_account}"
      "TAGITEMS"="${var.tag_items}"
    }

    max_instances                = 3000
    min_instances                = 0
    name                         = "instanceResume"
    project                      = "${var.project}"
    region                       = "${var.region}"
    runtime                      = "${var.runtime}"
    service_account_email        = "${var.project}@appspot.gserviceaccount.com"
    timeout                      = 60
    trigger_http                 = true

    timeouts {}
    source_archive_bucket = google_storage_bucket.functions_store.name
    source_archive_object = google_storage_bucket_object.resume_function_code.name

}

# google_cloudfunctions_function.suspend_func:
resource "google_cloudfunctions_function" "suspend_func" {
    available_memory_mb          = 256
    docker_registry              = "CONTAINER_REGISTRY"
    entry_point                  = "arr_suspend_func"
    https_trigger_security_level = "SECURE_OPTIONAL"
    https_trigger_url            = "https://${var.region}-${var.project}.cloudfunctions.net/suspend_func"
    ingress_settings             = "ALLOW_ALL"
    labels                       = {
        "deployment-tool" = "console-cloud"
    }
    environment_variables = {
      "PROJECT_ID" = "${var.project}"
      "SERVICE_ACCOUNT"="${var.service_account}"
      "TAGITEMS"="${var.tag_items}"
    }

    max_instances                = 3000
    min_instances                = 0
    name                         = "instanceSuspend"
    project                      = "${var.project}"
    region                       = "${var.region}"
    runtime                      = "${var.runtime}"
    service_account_email        = "${var.project}@appspot.gserviceaccount.com"
    timeout                      = 60
    trigger_http                 = true
    timeouts {}
    source_archive_bucket = google_storage_bucket.functions_store.name
    source_archive_object = google_storage_bucket_object.suspend_function_code.name
}


# google_cloud_scheduler_job.resume_func:
resource "google_cloud_scheduler_job" "resume_func" {
    attempt_deadline = "180s"
    name             = "resume_func"
    project          = "${var.project}"
    region           = "${var.region}"
    schedule         = "15 * * * *"
    time_zone        = "Asia/Jerusalem"

    http_target {
        headers     = {}
        http_method = "POST"
        uri         = "https://${var.region}-${var.project}.cloudfunctions.net/resume_func"

        oidc_token {
            audience              = "https://${var.region}-${var.project}.cloudfunctions.net/resume_func"
            service_account_email = "${var.project}@appspot.gserviceaccount.com"
        }
    }

    retry_config {
        max_backoff_duration = "3600s"
        max_doublings        = 5
        max_retry_duration   = "0s"
        min_backoff_duration = "5s"
        retry_count          = 0
    }

    timeouts {}
}

# google_cloud_scheduler_job.suspend_func:
resource "google_cloud_scheduler_job" "suspend_func" {
    attempt_deadline = "180s"
    name             = "suspend_func"
    project          = "${var.project}"
    region           = "${var.region}"
    schedule         = "0 * * * *"
    time_zone        = "Asia/Jerusalem"

    http_target {
        headers     = {}
        http_method = "POST"
        uri         = "https://${var.region}-${var.project}.cloudfunctions.net/suspend_func"

        oidc_token {
            audience              = "https://${var.region}-${var.project}.cloudfunctions.net/suspend_func"
            service_account_email = "${var.project}@appspot.gserviceaccount.com"
        }
    }

    retry_config {
        max_backoff_duration = "3600s"
        max_doublings        = 5
        max_retry_duration   = "0s"
        min_backoff_duration = "5s"
        retry_count          = 0
    }

    timeouts {}
}
