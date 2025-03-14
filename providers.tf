terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0.4"
    }
  }
}

provider "snowflake" {
  profile = "tfconn"
  alias   = "security_admin"
  role    = "SECURITYADMIN"
}

provider "snowflake" {
  profile                  = "tfconn"
  role                     = "SYSADMIN"
  preview_features_enabled = ["snowflake_table_resource", "snowflake_file_format_resource", "snowflake_stage_resource"]
  warehouse                = "COMPUTE_WH"
}