resource "aws_ecs_cluster" "cluster" {
  name               = var.ecs["cluster_name"]
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "100"
  }
}

resource "aws_ecs_task_definition" "task" {
  family = "users_api"
  requires_compatibilities = [
    "FARGATE",
  ]
  execution_role_arn = aws_iam_role.fargate.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([
    {
      name      = var.ecs["container_name"]
      image     = var.ecs["container_image"]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/users_api",
          awslogs-region        = "eu-central-1",
          awslogs-stream-prefix = "ecs"
        }
      }

      portMappings = [
        for port in var.ecs["ports"] :
        {
          containerPort = port
          hostPort      = port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.ecs["service_name"]
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = false
    security_groups  = var.security_groups
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.ecs["container_name"]
    container_port   = var.ecs["container_port"]
  }
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

resource "aws_iam_user" "publisher" {
  name = "ecr-publisher"
  path = "/"
}

resource "aws_iam_role" "fargate" {
  name = "fargate-role"
  path = "/serviceaccounts/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })
}


resource "aws_iam_user_policy" "publisher" {
  name = "ecr-publisher"
  user = aws_iam_user.publisher.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ecs:UpdateService",
              "ecr:*",
              "ecs:DescribeServices"
          ],
          "Resource": [
              "arn:aws:ecs:*:*:service/${var.ecs["cluster_name"]}/*",
              "arn:aws:ecs:*:*:service/${var.ecs["cluster_name"]}",
              "arn:aws:ecr:*:*:repository/${var.ecs["repo_name"]}"
          ]
      },
      {
          "Effect": "Allow",
          "Action": [
              "iam:PassRole",
              "iam:GetRole",
              "ecr:GetRegistryPolicy",
              "ecs:RegisterTaskDefinition",
              "ecr:DescribeRegistry",
              "ecr:GetAuthorizationToken",
              "ecr:DeleteRegistryPolicy",
              "ecr:PutRegistryPolicy",
              "ecs:DescribeTaskDefinition",
              "ecr:PutReplicationConfiguration"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_access_key" "publisher" {
  user = aws_iam_user.publisher.name
}

resource "aws_iam_role_policy" "fargate" {
  name = "fargate-execution-role"
  role = aws_iam_role.fargate.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:ListTagsLogGroup",
        "logs:GetLogRecord",
        "logs:DescribeLogStreams",
        "logs:StartQuery",
        "ecr:ListImages",
        "logs:GetLogDelivery",
        "logs:DeleteLogStream",
        "logs:ListLogDeliveries",
        "logs:CreateLogStream",
        "logs:TagLogGroup",
        "ecr:CompleteLayerUpload",
        "logs:GetLogEvents",
        "ecr:DescribeRepositories",
        "logs:FilterLogEvents",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetLifecyclePolicy",
        "ecr:GetRegistryPolicy",
        "ecr:DescribeImageScanFindings",
        "logs:DescribeLogGroups",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:GetDownloadUrlForLayer",
        "ecr:DescribeRegistry",
        "ecr:GetAuthorizationToken",
        "logs:StopQuery",
        "logs:TestMetricFilter",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:CreateLogDelivery",
        "logs:GetQueryResults",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "logs:GetLogGroupFields",
        "ecr:GetRepositoryPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}