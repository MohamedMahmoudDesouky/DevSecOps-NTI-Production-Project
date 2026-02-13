# imports.tf

import {
  to = module.ecr.aws_ecr_repository.backend
  id = "capstone-project-backend"
}

import {
  to = module.ecr.aws_ecr_repository.frontend
  id = "capstone-project-frontend"
}
