terraform {
  backend "remote" {
    hostname     = "casper.scalr.io"
    organization = "env-ue0ui632pvskegg"

    workspaces {
      name = "cloudtrail"
    }
  }
}