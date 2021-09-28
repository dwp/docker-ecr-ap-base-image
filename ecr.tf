resource "aws_ecr_repository" "docker-ecr-template" {
  name = "docker-ecr-template"
  tags = merge(
    local.common_tags,
    { DockerHub : "dwpdigital/docker-ecr-template" }
  )
}

resource "aws_ecr_repository_policy" "docker-ecr-template" {
  repository = aws_ecr_repository.docker-ecr-template.name
  policy     = data.terraform_remote_state.management.outputs.ecr_iam_policy_document
}

output "ecr_example_url" {
  value = aws_ecr_repository.docker-ecr-template.repository_url
}
