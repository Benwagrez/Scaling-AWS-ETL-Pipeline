# ========================= #
# === S3 Bucket details === #
# ========================= #
# Purpose
# Deploy data bucket
#
################################################
########## S3 bucket for data output ###########
################################################
resource "aws_s3_bucket" "data_output_bucket" {
  bucket = var.DataOutputBucketName

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "${var.DataOutputBucketName}",
    })
  )}" 
}

resource "aws_s3_bucket_ownership_controls" "data_output_bucket_acl_ownership" {
  bucket = aws_s3_bucket.data_output_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "data_output_bucket_access" {
  bucket = aws_s3_bucket.data_output_bucket.id

  block_public_acls       = true 
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false 
}

resource "aws_s3_bucket_policy" "data_output_bucket_S3_private_read_only" {
  bucket = aws_s3_bucket.data_output_bucket.id
  policy = templatefile("${path.module}/bucket_policy/s3-output-bucket-policy.json", { bucket = var.DataOutputBucketName, AWSTERRAFORMSPN = var.TerraformSPNArn })
  depends_on = [aws_s3_bucket_ownership_controls.data_output_bucket_acl_ownership]
}
