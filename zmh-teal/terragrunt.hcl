generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "homelab/zmh-teal/terraform.tfstate"
    region = "us-east-1"
    endpoint = "http://s3.lavender.chillpickles.digital"
    force_path_style = true
    access_key = "${jsondecode(file(/home/zmaier/.s3/tf-backend.json)).minio.access-key}"
    secret_key = "${jsondecode(file(/home/zmaier/.s3/tf-backend.json)).minio.secret-key}"
    skip_credentials_validation = true
    skip_region_validation = true
    skip_metadata_api_check = true
  }
}
EOF
}