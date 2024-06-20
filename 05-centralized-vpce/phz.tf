resource "aws_route53_zone" "phz" {
  name = "${data.aws_caller_identity.current.account_id}-example.com"

  vpc {
    vpc_id = module.vpc_vpce.vpc_id
  }

  vpc {
    vpc_id = module.vpc_spoke1.vpc_id
  }

  vpc {
    vpc_id = module.vpc_spoke2.vpc_id
  }
}
