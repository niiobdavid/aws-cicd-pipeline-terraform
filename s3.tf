# Bucket that CodePipeline uses to pass artifacts between stages
resource "aws_s3_bucket" "artifacts" {
  bucket        = local.bucket_name
  force_destroy = true # lets `terraform destroy` delete it even when it still has artifacts in it
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
