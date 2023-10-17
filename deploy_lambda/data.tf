data "aws_ecr_image" "service_image" {
  repository_name = "my/service"
  image_tag       = "latest"
}