variable "region" {
  type = string
  description = "The region that AWS will default to"
  nullable = false
}

variable "domain" {
  type = string
  description = "The domain to host on"
  nullable = false
}

variable "base_domain" {
  type = string
  description = "If domain is a subdomain, then this needs to be the root domain in order to find the hosted zone"
}

variable "name" {
  type = string
  description = "The name of the deployment"
  default = "swf_akk_li_homage"
}
