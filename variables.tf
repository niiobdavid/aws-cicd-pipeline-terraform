variable "aws_region" {
  description = "AWS region to build everything in"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Base name used for CodeBuild, CodeDeploy, CodePipeline and the CodeArtifact repository"
  type        = string
  default     = "nextwork-devops-cicd"
}

variable "your_name" {
  description = "Your name in lowercase, used to make the S3 bucket name unique"
  type        = string
  default     = "nii"
}

variable "codeartifact_domain" {
  description = "CodeArtifact domain name (must match the URL in your settings.xml)"
  type        = string
  default     = "nextwork"
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
  default     = "niiobdavid/nextwork-web-project"
}

variable "github_branch" {
  description = "Branch that triggers the pipeline"
  type        = string
  default     = "master"
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidr" {
  description = "Who can open the web app on port 80. 0.0.0.0/0 = anyone; use \"<your-ip>/32\" to restrict it to you"
  type        = string
  default     = "0.0.0.0/0"
}
