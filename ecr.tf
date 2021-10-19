resource "aws_ecr_repository" "docker-ecr-ap-base-image" {
  name = "docker-ecr-ap-base-image"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    { DockerHub : "dwpdigital/docker-ecr-ap-base-image" }
  )
}

resource "aws_ecr_repository_policy" "docker-ecr-ap-base-image" {
  repository = aws_ecr_repository.docker-ecr-ap-base-image.name
  policy     = data.terraform_remote_state.management.outputs.ecr_iam_policy_document
}

output "ecr_docker-ecr-ap-base-image_url" {
  value = aws_ecr_repository.docker-ecr-ap-base-image.repository_url
}
