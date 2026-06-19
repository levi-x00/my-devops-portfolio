# My AWS Lambda Template

### Disclaimer

Please note that this terraform AWS lambda only available for Python runtime for now, you guys can freely modify `my-lambda` module

### Example

This is the example how to use the lambda module, you can check the `lambda-test` folder for more complete guide

```terraform
module "lambda-test" {
  source      = "../modules/lambda"
  lambda_name = "lambda-test"

  runtime     = "python3.9"
  timeout     = 20
  memory_size = 256
  handler     = "lambda_function.lambda_handler"

  source_dir = "${path.module}/src"
  output_dir = "${path.module}/archived"

  security_group_ids = []
  subnet_ids         = []

  lambda_inline_policy = data.aws_iam_policy_document.inline_policy.json

  tags = var.tags
}
```
