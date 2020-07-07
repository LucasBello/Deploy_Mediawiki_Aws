provider "aws" {
  region = var.aws_region
}

resource "dns_cname_record" "dns_wiki" {
  zone  = "vinnland.ml"
  name  = "mediawiki"
  cname = "MediaWikiELB-1429975875.us-west-2.elb.amazonaws.com"
  ttl   = 3600
}