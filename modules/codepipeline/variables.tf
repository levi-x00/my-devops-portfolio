variable "name" {
  description = "The identifier for the Code pipeline"
  type        = string
}

variable "iam_role_arn" {
  type        = string
  default     = null
  description = "The service IAM role ARN that allows pipeline. If not provided, a role will be created by the module."
}

variable "policy_arns" {
  type        = list(string)
  default     = []
  description = "List of IAM policy ARNs to attach to the module-managed role. Only used when iam_role_arn is not provided."
}

variable "artifact_store" {
  type = list(object({
    location = string
    type     = string
  }))
  default     = null
  description = <<-DOC
     Configuration of artifact for CodePipeline.
      location:
        For the S3 bucket, use S3 ARN.
      type:
        For the S3 bucket, use "S3".
  DOC
}

variable "stage" {
  type = list(object({
    name             = string
    action_name      = string
    category         = string
    owner            = string
    provider         = string
    version          = string
    namespace        = optional(string)
    run_order        = optional(number)
    role_arn         = optional(string)
    region           = optional(string)
    input_artifacts  = optional(list(string))
    output_artifacts = optional(list(string))
    configuration    = optional(map(string))
  }))
  description = "Stages for CodePipeline"
  default     = []

  validation {
    condition     = length([for item in var.stage : item.category if contains(["Source", "Build", "Deploy", "Test", "Invoke", "Approval"], item.category)]) == length(var.stage)
    error_message = "Category must be one of: 'Source', 'Build', 'Deploy', 'Test', 'Invoke' or 'Approval'."
  }

  validation {
    condition     = length([for item in var.stage : item.owner if contains(["AWS", "Custom", "ThirdParty"], item.owner)]) == length(var.stage)
    error_message = "Owner must be one of: 'AWS', 'Custom' or 'ThirdParty'."
  }

  validation {
    condition     = length([for item in var.stage : item.category if contains(["Approval", "Build", "Deploy", "Invoke", "Source", "Test"], item.category)]) == length(var.stage)
    error_message = "Owner must be one of: 'Approval', 'Build', 'Deploy', 'Invoke', 'Source' or 'Test'."
  }
}

variable "tags" {
  description = "A list of tags as identifier"
  type        = map(string)
  default     = {}
}
