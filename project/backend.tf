terraform {
  backend "gcs" {
    bucket = "tf-project-states"
    prefix = "whitelama"
  }
}