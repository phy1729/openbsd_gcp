variable "account_file" {
  type        = string
  description = "The JSON file containing your account credentials."
  default     = "account.json"
}

variable "project_id" {
  type        = string
  description = "The project ID where the GCS bucket exists and where the GCE image is stored."
}

variable "bucket" {
  type        = string
  description = "The name of the GCS bucket where the raw disk image will be uploaded."
}

variable "version" {
  type        = string
  description = "OpenBSD version number without the dot."
  default     = "70"
}

source "openbsd-vmm" "openbsd" {
  vm_name     = "disk" # Required so the disk name is disk.raw
  vm_template = "generic"
  disk_format = "raw"
  disk_size   = "30G"
  cdrom       = "install${var.version}.iso"
  boot_wait   = "5s"
  boot_command = [
    "<wait5>A<enter><wait5>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/install.conf<enter>"
  ]

  communicator = "none"

  http_directory = "./http"
  http_port_min  = 1729
  http_port_max  = 1729

  log_directory    = "."
  output_directory = "out"
}

build {
  sources = ["source.openbsd-vmm.openbsd"]

  post-processors {
    post-processor "compress" {
      output = "out/disk.raw.tar.gz"
    }

    post-processor "googlecompute-import" {
      account_file = var.account_file
      project_id   = var.project_id
      bucket       = var.bucket
      image_name   = "openbsd${var.version}"
    }
  }
}
