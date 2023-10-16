output "outputbucketid" {
  value = aws_s3_bucket.data_output_bucket.id
}

output "tableau_spn_name" {
  value = aws_iam_user.data_spn.name
}