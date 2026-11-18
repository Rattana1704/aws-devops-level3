terraform {
  backend "s3" {
    bucket       = "rattana-rueanmoon-apl-tfstate-573535109120-20261118123946"
    key          = "devops.school"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}
