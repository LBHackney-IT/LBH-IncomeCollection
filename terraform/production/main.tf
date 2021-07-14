provider "aws" {
  region  = "eu-west-2"
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  application_name = "lbh income collection"
  parameter_store = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter"
}

data "aws_ssm_parameter" "manage_arrears_aad_client_id" {
  name = "/housing-finance/production/aad_client_id"
}
data "aws_ssm_parameter" "manage_arrears_aad_tenant" {
  name = "/housing-finance/production/aad_tenant"
}
data "aws_ssm_parameter" "manage_arrears_basic_auth_password" {
  name = "/housing-finance/production/basic_auth_password"
}
data "aws_ssm_parameter" "manage_arrears_basic_auth_username" {
  name = "/housing-finance/production/basic_auth_username"
}
data "aws_ssm_parameter" "manage_arrears_database_url" {
  name = "/housing-finance/production/database-url"
}
data "aws_ssm_parameter" "manage_arrears_gov_notify_api_key" {
  name = "/housing-finance/production/gov-notify-api-key"
}
data "aws_ssm_parameter" "manage_arrears_gov_notify_sender_id" {
  name = "/housing-finance/production/gov-notify-sender-id"
}
data "aws_ssm_parameter" "manage_arrears_hackney_api_key" {
  name = "/housing-finance/production/hackney-api-key"
}
data "aws_ssm_parameter" "manage_arrears_hackney_jwt_secret" {
  name = "/housing-finance/production/hackney_jwt_secret"
}
data "aws_ssm_parameter" "manage_arrears_hotjar_key" {
  name = "/housing-finance/production/hotjar_key"
}
data "aws_ssm_parameter" "manage_arrears_hotjar_version" {
  name = "/housing-finance/production/hotjar_version"
}
data "aws_ssm_parameter" "manage_arrears_ic_staff_group" {
  name = "/housing-finance/production/ic_staff_group"
}
data "aws_ssm_parameter" "manage_arrears_income_api_key" {
  name = "/housing-finance/production/income_api_key"
}
data "aws_ssm_parameter" "manage_arrears_income_api_url" {
  name = "/housing-finance/production/income_api_url"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_api_host" {
  name = "/housing-finance/production/income_collection_api_host"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_api_key" {
  name = "/housing-finance/production/income-collection_api_key"
}
data "aws_ssm_parameter" "manage_arrears_income_collection_list_api_host" {
  name = "/housing-finance/production/income_collection_list_api_host"
}
data "aws_ssm_parameter" "manage_arrears_lang" {
  name = "/housing-finance/production/lang"
}
data "aws_ssm_parameter" "manage_arrears_rack_env" {
  name = "/housing-finance/production/rack-env"
}
data "aws_ssm_parameter" "manage_arrears_rails_env" {
  name = "/housing-finance/production/rails-env"
}
data "aws_ssm_parameter" "manage_arrears_rails_log_to_stdout" {
  name = "/housing-finance/production/rails-log-to-stdout"
}
data "aws_ssm_parameter" "manage_arrears_rails_serve_static_files" {
  name = "/housing-finance/production/rails-serve-static-files"
}
data "aws_ssm_parameter" "manage_arrears_secret_key_base" {
  name = "/housing-finance/production/secret-key-base"
}
data "aws_ssm_parameter" "manage_arrears_send_live_communications" {
  name = "/housing-finance/production/send-live-communications"
}
data "aws_ssm_parameter" "manage_arrears_sentry_dsn" {
  name = "/housing-finance/production/sentry-dsn"
}
data "aws_ssm_parameter" "manage_arrears_tenancy_api_key" {
  name = "/housing-finance/production/tenancy-api-key"
}
data "aws_ssm_parameter" "manage_arrears_tenancy_api_url" {
  name = "/housing-finance/production/tenancy-api-url"
}
data "aws_ssm_parameter" "manage_arrears_test_email_address" {
  name = "/housing-finance/production/test-email-address"
}
data "aws_ssm_parameter" "manage_arrears_test_phone_number" {
  name = "/housing-finance/production/test-phone-number"
}
data "aws_ecs_cluster" "ecs_cluster_for_manage_arrears" {
  cluster_name = "ecs-cluster-for-manage-arrears"
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-housing-production"
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
    subnets          = ["subnet-0ba272bb1ba6226d1","subnet-0309dff957b6f825e"]
    security_groups = ["sg-01396d0029aa1c950"]
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
  execution_role_arn       = "arn:aws:iam::282997303675:role/ecsTaskExecutionRole"
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.app_name}-container",
    "image": "282997303675.dkr.ecr.eu-west-2.amazonaws.com/hackney/apps/income-collection:latest",
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
  name               = "lb-${var.app_name}-2"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-0ba272bb1ba6226d1","subnet-0309dff957b6f825e"]
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
  vpc_id      = "vpc-0ce853ddb64e8fb3c"
  target_type = "ip"
  stickiness {
    enabled = false
    type = "app_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# Redirect all traffic from the NLB to the target group
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = 443
  protocol    = "TLS"
  certificate_arn = "arn:aws:acm:eu-west-2:282997303675:certificate/d8f32bef-429a-408e-9fa9-3f0d2ec72ef4"
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
  aliases = ["managearrears.hackney.gov.uk"]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for manage arrears front end"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:282997303675:certificate/a43b1303-83ff-496e-b7a2-a75fa3ebfe87"
    ssl_support_method = "sni-only"
  }
}
