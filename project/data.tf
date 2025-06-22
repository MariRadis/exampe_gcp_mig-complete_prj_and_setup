data "terraform_remote_state" "bootstrap" {
  backend = "local" # or "gcs" if using remote backend
  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}
