
# define aws providers
provider "aws" {
  region = "${var.first_region}"
  alias = "west"
}

provider "aws" {
  region = "${var.second_region}"
  alias = "east"
}
