resource "aws_codeartifact_domain" "this" {
  domain = var.codeartifact_domain
}

# Proxy repository connected to the public Maven Central
resource "aws_codeartifact_repository" "maven_central_store" {
  repository = "maven-central-store"
  domain     = aws_codeartifact_domain.this.domain

  external_connections {
    external_connection_name = "public:maven-central"
  }
}

# The repository your settings.xml points at; pulls from maven-central-store upstream
resource "aws_codeartifact_repository" "app" {
  repository = var.project_name
  domain     = aws_codeartifact_domain.this.domain

  upstream {
    repository_name = aws_codeartifact_repository.maven_central_store.repository
  }
}
