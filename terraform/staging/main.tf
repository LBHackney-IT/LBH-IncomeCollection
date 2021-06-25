provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.0"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  application_name = "lbh income collection"
  parameter_store = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"
}

data "aws_ssm_parameter" "manage_arrears_aad_client_id" {
  name = "/manage-arrears/${var.environment_name}/aad-client-id"
}
data "aws_ssm_parameter" "manage_arrears_aad_tenant" {
  name = "/manage-arrears/${var.environment_name}/aad-tenant"
}
data "aws_ssm_parameter" "manage_arrears_basic_auth_password" {
  name = "/manage-arrears/${var.environment_name}/basic-auth-password"
}
data "aws_ssm_parameter" "manage_arrears_basic_auth_username" {
  name = "/manage-arrears/${var.environment_name}/basic-auth-username"
}
data "aws_ssm_parameter" "manage_arrears_database_url" {
  name = "/manage-arrears/${var.environment_name}/database-url"
}
data "aws_ssm_parameter" "manage_arrears_gov_notify_api_key" {
  name = "/manage-arrears/${var.environment_name}/gov-notify-api-key"
}
data "aws_ssm_parameter" "manage_arrears_gov_notify_sender_id" {
  name = "/manage-arrears/${var.environment_name}/gov-notify-sender-id"
}
data "aws_ssm_parameter" "manage_arrears_hackney_api_key" {
  name = "/manage-arrears/${var.environment_name}/hackney-api-key"
}
data "aws_ssm_parameter" "manage_arrears_hackney_jwt_secret" {
  name = "/manage-arrears/${var.environment_name}/hackney-jwt-secret"
}
data "aws_ssm_parameter" "manage_arrears_hotjar_key" {
  name = "/manage-arrears/${var.environment_name}/hotjar-key"
}
data "aws_ssm_parameter" "manage_arrears_hotjar_version" {
  name = "/manage-arrears/${var.environment_name}/hotjar-version"
}
data "aws_ssm_parameter" "manage_arrears_ic_staff_group" {
  name = "/manage-arrears/${var.environment_name}/ic-staff-group"
}
data "aws_ssm_parameter" "manage_arrears_income_api_key" {
  name = "/manage-arrears/${var.environment_name}/income-api-key"
}
data "aws_ssm_parameter" "manage_arrears_income_api_url" {
  name = "/manage-arrears/${var.environment_name}/income-api-url"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_api_host" {
  name = "/manage-arrears/${var.environment_name}/income-collection-api-host"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_api_key" {
  name = "/manage-arrears/${var.environment_name}/income-collection-api-key"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_list_api_host" {
  name = "/manage-arrears/${var.environment_name}/income-collection-list-api-host"
}
data "aws_ssm_parameter" "manage_arrears_lang" {
  name = "/manage-arrears/${var.environment_name}/lang"
}
data "aws_ssm_parameter" "manage_arrears_rack_env" {
  name = "/manage-arrears/${var.environment_name}/rack-env"
}
data "aws_ssm_parameter" "manage_arrears_rails_env" {
  name = "/manage-arrears/${var.environment_name}/rails-env"
}
data "aws_ssm_parameter" "manage_arrears_rails_log_to_stdout" {
  name = "/manage-arrears/${var.environment_name}/rails-log-to-stdout"
}
data "aws_ssm_parameter" "manage_arrears_rails_serve_static_files" {
  name = "/manage-arrears/${var.environment_name}/rails-serve-static-files"
}
data "aws_ssm_parameter" "manage_arrears_secret_key_base" {
  name = "/manage-arrears/${var.environment_name}/secret-key-base"
}
data "aws_ssm_parameter" "manage_arrears_send_live_communications" {
  name = "/manage-arrears/${var.environment_name}/send-live-communications"
}
data "aws_ssm_parameter" "manage_arrears_sentry_dsn" {
  name = "/manage-arrears/${var.environment_name}/sentry-dsn"
}
data "aws_ssm_parameter" "manage_arrears_tenancy_api_key" {
  name = "/manage-arrears/${var.environment_name}/tenancy-api-key"
}
data "aws_ssm_parameter" "manage_arrears_tenancy_api_url" {
  name = "/manage-arrears/${var.environment_name}/tenancy-api-url"
}
data "aws_ssm_parameter" "manage_arrears_test_email_address" {
  name = "/manage-arrears/${var.environment_name}/test-email-address"
}
data "aws_ssm_parameter" "manage_arrears_test_phone_number" {
  name = "/manage-arrears/${var.environment_name}/test-phone-number"
}
data "aws_ecs_cluster" "ecs_cluster_for_manage_arrears" {
  cluster_name = "ecs-cluster-for-manage-arrears"
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-staging"
    encrypt = true
    region  = "eu-west-2"
    key     = "services/lbh-income-collection/state"
  }
}

resource "aws_ecr_repository" "income-collection" {
  name                 = "hackney/apps/income-collection"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "income-collection-policy" {
  repository = aws_ecr_repository.income-collection.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "logs:CreateLogGroup"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecs_service" "income-collection-ecs-service" {
  name            = "income-collection-ecs-service"
  cluster         = data.aws_ecs_cluster.ecs_cluster_for_manage_arrears.id
  task_definition = aws_ecs_task_definition.income-collection-ecs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-0743d86e9b362fa38","subnet-0ea0020a44b98a2ca"]
    security_groups = ["sg-0be329a40ea5c4828"]
    assign_public_ip = true
  }
  desired_count = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "${var.app_name}-container"
    container_port   = var.app_port
  }
}

resource "aws_ecs_task_definition" "income-collection-ecs-task-definition" {
  family                   = "ecs-task-definition-income-collection"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::087586271961:role/ecsTaskExecutionRole"
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.app_name}-container",
    "image": "087586271961.dkr.ecr.eu-west-2.amazonaws.com/hackney/apps/income-collection:latest",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.app_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "ecs-task-definition-${var.app_name}",
            "awslogs-region": "eu-west-2",
            "awslogs-stream-prefix": "${var.app_name}-logs"
        }
    },
    "environment": [
      {
        "name": "AAD_CLIENT_ID",
        "value": "${data.aws_ssm_parameter.manage_arrears_aad_client_id.value}"
      },
      {
        "name": "AAD_TENANT",
        "value": "${data.aws_ssm_parameter.manage_arrears_aad_tenant.value}"
      },
      {
        "name": "BASIC_AUTH_PASSWORD",
        "value": "${data.aws_ssm_parameter.manage_arrears_basic_auth_password.value}"
      },
      {
        "name": "BASIC_AUTH_USERNAME",
        "value": "${data.aws_ssm_parameter.manage_arrears_basic_auth_username.value}"
      },
      {
        "name": "DATABASE_URL",
        "value": "${data.aws_ssm_parameter.manage_arrears_database_url.value}"
      },
      {
        "name": "GOV_NOTIFY_API_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_gov_notify_api_key.value}"
      },
      {
        "name": "GOV_NOTIFY_SENDER_ID",
        "value": "${data.aws_ssm_parameter.manage_arrears_gov_notify_sender_id.value}"
      },
      {
        "name": "HACKNEY_API_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_hackney_api_key.value}"
      },
      {
        "name": "HACKNEY_JWT_SECRET",
        "value": "${data.aws_ssm_parameter.manage_arrears_hackney_jwt_secret.value}"
      },
      {
        "name": "HOTJAR_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_hotjar_key.value}"
      },
      {
        "name": "HOTJAR_VERSION",
        "value": "${data.aws_ssm_parameter.manage_arrears_hotjar_version.value}"
      },
      {
        "name": "IC_STAFF_GROUP",
        "value": "${data.aws_ssm_parameter.manage_arrears_ic_staff_group.value}"
      },
      {
        "name": "INCOME_API_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_income_api_key.value}"
      },
      {
        "name": "INCOME_API_URL",
        "value": "${data.aws_ssm_parameter.manage_arrears_income_api_url.value}"
      },
      {
        "name": "INCOME_COLLECTION_API_HOST",
        "value": "${data.aws_ssm_parameter.manage_arrears_income_collection_api_host.value}"
      },
      {
        "name": "INCOME_COLLECTION_API_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_income_collection_api_key.value}"
      },
      {
        "name": "INCOME_COLLECTION_LIST_API_HOST",
        "value": "${data.aws_ssm_parameter.manage_arrears_income_collection_list_api_host.value}"
      },
      {
        "name": "LANG",
        "value": "${data.aws_ssm_parameter.manage_arrears_lang.value}"
      },
      {
        "name": "RACK_ENV",
        "value": "${data.aws_ssm_parameter.manage_arrears_rack_env.value}"
      },
      {
        "name": "RAILS_ENV",
        "value": "${data.aws_ssm_parameter.manage_arrears_rails_env.value}"
      },
      {
        "name": "RAILS_LOG_TO_STDOUT",
        "value": "${data.aws_ssm_parameter.manage_arrears_rails_log_to_stdout.value}"
      },
      {
        "name": "RAILS_SERVE_STATIC_FILES",
        "value": "${data.aws_ssm_parameter.manage_arrears_rails_serve_static_files.value}"
      },
      {
        "name": "SECRET_KEY_BASE",
        "value": "${data.aws_ssm_parameter.manage_arrears_secret_key_base.value}"
      },
      {
        "name": "SEND_LIVE_COMMUNICATIONS",
        "value": "${data.aws_ssm_parameter.manage_arrears_send_live_communications.value}"
      },
      {
        "name": "SENTRY_DSN",
        "value": "${data.aws_ssm_parameter.manage_arrears_sentry_dsn.value}"
      },
      {
        "name": "TENANCY_API_KEY",
        "value": "${data.aws_ssm_parameter.manage_arrears_tenancy_api_key.value}"
      },
      {
        "name": "TENANCY_API_URL",
        "value": "${data.aws_ssm_parameter.manage_arrears_tenancy_api_url.value}"
      },
      {
        "name": "TEST_EMAIL_ADDRESS",
        "value": "${data.aws_ssm_parameter.manage_arrears_test_email_address.value}"
      },
      {
        "name": "TEST_PHONE_NUMBER",
        "value": "${data.aws_ssm_parameter.manage_arrears_test_phone_number.value}"
      }
    ]
  }
]
DEFINITION
}

# Network Load Balancer (NLB) setup
resource "aws_lb" "lb" {
  name               = "lb-${var.app_name}"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-0743d86e9b362fa38","subnet-0ea0020a44b98a2ca"]
  enable_deletion_protection = false
  tags = {
    Environment = var.environment_name
  }
}
resource "aws_lb_target_group" "lb_tg" {
  depends_on  = [
    aws_lb.lb
  ]
  name_prefix = "ma-tg-"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = "vpc-064521a7a4109ba31"
  target_type = "ip"
  stickiness {
    enabled = false
    type = "lb_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = 80
  protocol    = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.id
    type             = "forward"
  }
}

# Cloudfront Distribution
locals {
  income_collection_origin_id = "income-collection"
}

resource "aws_cloudfront_distribution" "income_collection_distribution" {
  origin {
    domain_name = aws_lb.lb.dns_name
    origin_id   = local.income_collection_origin_id
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for manage arrears front end"
  default_root_object = "index.html"

  //  aliases = ["a valid url"] - probably not needed for dev but we'll need a proper url for production

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.income_collection_origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
