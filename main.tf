terraform {
  backend "gcs" {
    bucket = "test-gc-cloud"
    prefix = "terraform/state"
  }
}

module "github-repository" {
  source = "github.com/den-vasyliev/tf-github-repository"
  # source                   = "./modules/github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

module "gke_cluster" {
  source = "github.com/EvgenPavlyuchek/tf-google-gke-cluster"
  # source         = "./modules/google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

# module "kind_cluster" {
#   source = "github.com/den-vasyliev/tf-kind-cluster"
#   # source = "./modules/kind"
# }

module "flux_bootstrap" {
  source = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  # source            = "./modules/fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  # config_path       = module.gke_cluster.kubeconfig
  # config_path       = module.kind_cluster.kubeconfig
  config_path  = data.local_file.foo.filename
  github_token = var.GITHUB_TOKEN
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  # source    = "./modules/hashicorp-tls-keys"
  algorithm = "RSA"
}


data "local_file" "foo" {
  depends_on = [module.gke_cluster]
  filename   = module.gke_cluster.kubeconfig
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.9.1"
    }
  }
}

provider "github" {
  token = var.GITHUB_TOKEN
}

resource "github_repository_file" "yaml1" {
  depends_on = [module.flux_bootstrap]
  repository          = var.FLUX_GITHUB_REPO
  branch              = "main"
  file                = "${var.FLUX_GITHUB_TARGET_PATH}/demo/ns.yaml"
  content             = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: demo
EOF
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

resource "github_repository_file" "yaml2" {
  depends_on = [module.flux_bootstrap]
  repository          = var.FLUX_GITHUB_REPO
  branch              = "main"
  file                = "${var.FLUX_GITHUB_TARGET_PATH}/demo/tbot-gr.yaml"
  content             = <<EOF
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: tbot
  namespace: demo
spec:
  interval: 1m0s
  ref:
    # branch: main
    branch: develop
  url: https://github.com/EvgenPavlyuchek/tbot
EOF
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

resource "github_repository_file" "yaml3" {
  depends_on = [module.flux_bootstrap]
  repository          = var.FLUX_GITHUB_REPO
  branch              = "main"
  file                = "${var.FLUX_GITHUB_TARGET_PATH}/demo/tbot-hr.yaml"
  content             = <<EOF
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: tbot
  namespace: demo
spec:
  chart:
    spec:
      chart: ./helm
      reconcileStrategy: Revision
      # reconcileStrategy: ChartVersion
      sourceRef:
        kind: GitRepository
        name: tbot
  interval: 1m0s
  values:
    secret:
      secretValue: ${var.TELE_TOKEN}
EOF
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}