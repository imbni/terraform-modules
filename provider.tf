provider "google" {
  credentials = file("./auth.json")
  project     = "mohammad-notepad-dev-1"
  region      = "us-central1"
  version     = "~> 2.5.0"
}