resource "google_compute_instance_template" "default" {
  project = var.project
  region = var.region
  name = var.mig_name
  labels = var.labels
  metadata = var.metadata
  machine_type = var.machine_type
  tags = var.tags

  service_account {
    email = var.service_account_email
    scopes = var.service_account_scopes
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      subnetwork = network_interface.value["subnetwork"]
    }
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      boot = lookup(disk.value, "boot", false)
      auto_delete = lookup(disk.value, "auto_delete", false)
      mode = lookup(disk.value, "mode", "READ_WRITE")
      source_image = lookup(disk.value, "source_image", null)
      disk_type = lookup(disk.value, "type", "pd-standard")
      disk_size_gb = lookup(disk.value, "size_gb", 64)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  project = var.project
  region = var.region
  name = var.mig_name
  base_instance_name = var.mig_name
  wait_for_instances = true

  version {
    instance_template = google_compute_instance_template.default.id
  }

  update_policy {
    minimal_action = "RESTART"
    type = "PROACTIVE"
    max_surge_fixed = 0
    max_unavailable_fixed = 3
    replacement_method = "RECREATE"
    instance_redistribution_type = "NONE"
  }

  depends_on = [google_compute_instance_template.default]
}

resource "google_copute_region_per_instance_config" "default" {
  project = google_compute_instance_template.default.project
  region = google_compute_instance_template.default.region
  region_instance_group_manager = google_compute_region_instance_group_manager.default.name

  count = var.mig_size

  name = format("%s-%02s", var.mig_name, count.index+1)

  preserved_state {
    metadata = {
      type = "stateful"
    }
  }

  depends_on [google_compute_instance_template.default]
}
