output "web_app_url" {
  description = "Open this once a deployment has succeeded (http, not https)"
  value       = "http://${aws_instance.webserver.public_dns}"
}

output "github_connection_status" {
  description = "Must be AVAILABLE before the pipeline can pull from GitHub"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "approve_github_connection_here" {
  value = "https://${var.aws_region}.console.aws.amazon.com/codesuite/settings/connections?region=${var.aws_region}"
}

output "pipeline_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.this.name}/view?region=${var.aws_region}"
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "codeartifact_repository_url" {
  description = "Should match the <url> in your settings.xml"
  value       = "https://${var.codeartifact_domain}-${local.account_id}.d.codeartifact.${var.aws_region}.amazonaws.com/maven/${var.project_name}/"
}
