locals {
  image_tag       = "dev"
  tag_prefix_list = [local.image_tag]

  ecr_repo_name = "expense-tracker-api-repo"
}

# enabled force delete to clean up image on terraform destroy before being able to destroy ECR
resource "aws_ecr_repository" "app" {
  name         = local.ecr_repo_name
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        # Keep 1 tagged image
        rulePriority = 1
        description  = "Keep [${join(", ", local.tag_prefix_list)}] tagged latest image, never delete"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = local.tag_prefix_list
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        # Keep 3 tagged or untagged images
        rulePriority = 2
        description  = "Keep last 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}