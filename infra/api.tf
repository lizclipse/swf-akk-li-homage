locals {
  dist_zip = "${path.module}/../dist.zip"
  content  = "${path.module}/../content"

  tags = {
    Name = "swf.akk.li"
  }
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.name}_lambda"
  description   = "Core swf-akk-li function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  publish = true
  create_package         = false
  local_existing_package = local.dist_zip

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  tags = local.tags
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  cors_rule = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://${var.domain}"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

resource "aws_s3_object" "content" {
  for_each = fileset(local.content, "**")

  acl    = "public-read"
  bucket = module.s3_bucket.s3_bucket_id
  key    = each.value
  source = "${local.content}/${each.value}"
  etag   = filemd5("${local.content}/${each.value}")
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.name}_api"
  description   = "swf-akk-li API"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  domain_name                 = var.domain
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "GET /static/{file+}" = {
      integration_uri    = "https://${module.s3_bucket.s3_bucket_bucket_domain_name}/{file}"
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"
    }

    "GET /{swf}" = {
      lambda_arn = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
    }

    "$default" = {
      lambda_arn = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.name}_logs"
}

data "aws_route53_zone" "host" {
  name         = var.base_domain == null ? var.domain : var.base_domain
  private_zone = false
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.base_domain == null ? var.domain : var.base_domain
  zone_id     = data.aws_route53_zone.host.id

  subject_alternative_names = var.base_domain == null ? [] : [var.domain]

  wait_for_validation = true

  tags = local.tags
}
