project = "my-project"
region = "asia-east2"
mig_name = "test-mig"
mig_size = 1
machine_type = "n1-standard-1"
service_account_email = "my@sa.com"
metadata = {
  owner = "my-name"
}
labels = {
  app = "kafka"
}

tags = [
  "firewall-tag"
]

interfaces = [
  {
    subnetwork = "projects/my-project/regions/asia-east2/subnetworks/vpc1"
  },
  {
    subnetwork = "projects/my-project/regions/asia-east2/subnetworks/vpc2"
  }
]

disks = [
  {
    boot = true
    auto_delete = true
    mode = "READ_WRITE"
    type = "pd-standard"
    size_gb = 64
    image_family = "projects/my-project/global/images/family/ubuntu"
  },
  {
    boot = false
    auto_delete = false
    mode = "READ_WRITE"
    type = "pd-ssd"
    size_gb = 100
    image_family = null
  }
]
