# terraform database
resource "snowflake_database" "terraform" {
  name = "TERRAFORM"
}

# terraform warehouse
resource "snowflake_warehouse" "tf_data_engineer_wh" {
  name                = "TF_DATA_ENGINEER_WH"
  warehouse_size      = "XSMALL"
  warehouse_type      = "STANDARD"
  auto_suspend        = 30
  initially_suspended = true
  auto_resume         = true
  min_cluster_count   = 1
  max_cluster_count   = 10
  scaling_policy      = "ECONOMY"
  comment             = "TF Data Engineer Workload Warehouse"
}

# tf data engineer role
resource "snowflake_account_role" "tf_data_engineer" {
  name = "TF_DATA_ENGINEER"
}

resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_warehouse_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.tf_data_engineer_wh.name
  }
}

# grants usage on the database to the tf data engineer
resource "snowflake_grant_privileges_to_account_role" "terraform_usage_tf_data_engineer" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.terraform.name
  }
}

# grants create table and modify to tf data engineer
resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_create_grant" {
  privileges        = ["MODIFY", "CREATE TABLE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.ACQUIRED.fully_qualified_name
  }
}

# grants usage on the schema ACQUIRED for tf data engineer
resource "snowflake_grant_privileges_to_account_role" "acquired_usage_tf_data_engineer" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.ACQUIRED.fully_qualified_name
  }
}

# all in schema
resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_tables_grant" {
  privileges        = ["SELECT", "INSERT"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.ACQUIRED.fully_qualified_name
    }
  }
}

# future in database
resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_future_tables_grant" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.terraform.name
    }
  }
}

# grants usage on the schema INGESTED for tf data engineer
resource "snowflake_grant_privileges_to_account_role" "ingested_usage_tf_data_engineer" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.INGESTED.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_create_ingested_view" {
  privileges        = ["MODIFY", "CREATE VIEW"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.INGESTED.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_create_enriched_view" {
  privileges        = ["MODIFY", "CREATE VIEW"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.ENRICHED.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_create_presented_view" {
  privileges        = ["MODIFY", "CREATE VIEW"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.PRESENTED.fully_qualified_name
  }
}

# grants usage on the schema ENRICHED for tf data engineer
resource "snowflake_grant_privileges_to_account_role" "enriched_usage_tf_data_engineer" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.ENRICHED.fully_qualified_name
  }
}

# grants usage on the schema PRESENTED for tf data engineer
resource "snowflake_grant_privileges_to_account_role" "presented_usage_tf_data_engineer" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_engineer.name
  on_schema {
    schema_name = snowflake_schema.PRESENTED.fully_qualified_name
  }
}

# ACQUIRED schema made
resource "snowflake_schema" "ACQUIRED" {
  database = snowflake_database.terraform.name
  name     = "ACQUIRED"
}

# INGESTED schema made
resource "snowflake_schema" "INGESTED" {
  database = snowflake_database.terraform.name
  name     = "INGESTED"
}

# ENRICHED schema made
resource "snowflake_schema" "ENRICHED" {
  database = snowflake_database.terraform.name
  name     = "ENRICHED"
}

# PRESENTED schema made
resource "snowflake_schema" "PRESENTED" {
  database = snowflake_database.terraform.name
  name     = "PRESENTED"
}

# stage for ACQUIRED made
resource "snowflake_stage" "stg_acquired" {
  name     = "ACQUIRED"
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ACQUIRED.name
}

# file format for ACQUIRED made
resource "snowflake_file_format" "ff_csv_with_header" {
  name                         = "CSV_WITH_HEADER"
  database                     = snowflake_database.terraform.name
  schema                       = snowflake_schema.ACQUIRED.name
  format_type                  = "CSV"
  skip_header                  = 1
  null_if                      = ["NULL", "null", ",' '"]
  date_format                  = "DD-MM-YYYY"
  field_optionally_enclosed_by = "\""
}

# timesheets_v001 table made
resource "snowflake_table" "acq_timesheets_v001" {
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ACQUIRED.name
  name     = "TIMESHEETS_V001"
  column {
    name = "DATE"
    type = "DATE"
  }
  column {
    name = "DEPARTMENT_ID"
    type = "NUMBER"
  }
  column {
    name = "EMPLOYEE_ID"
    type = "VARCHAR"
  }
  column {
    name = "EMPLOYEE_NAME"
    type = "VARCHAR"
  }
  column {
    name = "HOURS_WORKED"
    type = "FLOAT"
  }
}

# timesheets_v002 table made
resource "snowflake_table" "acq_timesheets_v002" {
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ACQUIRED.name
  name     = "TIMESHEETS_V002"
  column {
    name = "DATE"
    type = "DATE"
  }
  column {
    name = "DEPARTMENT_ID"
    type = "NUMBER"
  }
  column {
    name = "EMPLOYEE_ID"
    type = "VARCHAR"
  }
  column {
    name = "EMPLOYEE_NAME"
    type = "VARCHAR"
  }
  column {
    name = "CLOCK_IN"
    type = "TIME"
  }
  column {
    name = "CLOCK_OUT"
    type = "TIME"
  }
}

# employees table made
resource "snowflake_table" "acq_employees" {
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ACQUIRED.name
  name     = "EMPLOYEES"
  column {
    name = "ID"
    type = "VARCHAR"
  }
  column {
    name = "NAME"
    type = "VARCHAR"
  }
  column {
    name = "DEPARTMENT_ID"
    type = "VARCHAR"
  }
  column {
    name = "GENDER"
    type = "VARCHAR"
  }
  column {
    name = "STREET"
    type = "VARCHAR"
  }
  column {
    name = "CITY"
    type = "VARCHAR"
  }
  column {
    name = "ZIP"
    type = "VARCHAR"
  }
  column {
    name = "COUNTRY"
    type = "VARCHAR"
  }
}

# departments table made
resource "snowflake_table" "acq_departments" {
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ACQUIRED.name
  name     = "DEPARTMENTS"
  column {
    name = "ID"
    type = "VARCHAR"
  }
  column {
    name = "NAME"
    type = "VARCHAR"
  }
}
# creates role tf data analyst 
resource "snowflake_account_role" "tf_data_analyst" {
  name = "TF_DATA_ANALYST"
}

# grants usage on warehouse
resource "snowflake_grant_privileges_to_account_role" "tf_data_analyst_warehouse_usage" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_analyst.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.tf_data_engineer_wh.name
  }
}

# grants usage on the database
resource "snowflake_grant_privileges_to_account_role" "database_usage_tf_data_analyst" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_analyst.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.terraform.name
  }
}

# grants ENRICHED usage
resource "snowflake_grant_privileges_to_account_role" "enriched_usage_tf_data_analyst" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_analyst.name
  on_schema {
    schema_name = snowflake_schema.ENRICHED.fully_qualified_name
  }
}

# grants PRESENTED usage
resource "snowflake_grant_privileges_to_account_role" "presented_usage_tf_data_analyst" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.tf_data_analyst.name
  on_schema {
    schema_name = snowflake_schema.PRESENTED.fully_qualified_name
  }
}

# grants select on all ENRICHED views
resource "snowflake_grant_privileges_to_account_role" "tf_data_analyst_enriched_existing" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.tf_data_analyst.fully_qualified_name
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.ENRICHED.fully_qualified_name
    }
  }
}

# grants select on all future ENRICHED views
resource "snowflake_grant_privileges_to_account_role" "tf_data_analyst_presented_existing" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.tf_data_analyst.fully_qualified_name
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.PRESENTED.fully_qualified_name
    }
  }
}

# grants select on all PRESENTED views
resource "snowflake_grant_privileges_to_account_role" "tf_data_analyst_enriched_future" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.tf_data_analyst.fully_qualified_name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.ENRICHED.fully_qualified_name
    }
  }
}

# grants select on all future PRESENTED views 
resource "snowflake_grant_privileges_to_account_role" "tf_data_analyst_presented_future" {
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.tf_data_analyst.fully_qualified_name
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.PRESENTED.fully_qualified_name
    }
  }
}


# resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_tag_gdpr" {
#   provider = snowflake.security_admin
#   privileges        = ["APPLY TAG"]
#   account_role_name = snowflake_account_role.tf_data_engineer.fully_qualified_name
#   on_account = true
#   # on_schema_object {
#   #   object_type     = "TAG"
#   #   object_name     = snowflake_tag.gdpr.fully_qualified_name  
#   # }
#   } 

#   resource "snowflake_grant_privileges_to_account_role" "tf_data_engineer_tag_gdpr_partial" {
#   provider = snowflake.security_admin
#   privileges        = ["APPLY TAG"]
#   account_role_name = snowflake_account_role.tf_data_engineer.fully_qualified_name
#   on_account = true
#   # on_schema_object {
#   #   object_type     = "TAG"
#   #   object_name     = snowflake_tag.gdpr_partial_name.fully_qualified_name  
#   # }
#   }

resource "snowflake_masking_policy" "personal_data" {
  name     = "personal_data"
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ENRICHED.name
  argument {
    name = "val"
    type = "varchar"
  }
  body             = <<-EOP
  CASE 
       WHEN CURRENT_ROLE() = '${snowflake_account_role.tf_data_engineer.name}' THEN val
       ELSE '*******'
  END
EOP
  return_data_type = "varchar"
}

resource "snowflake_tag" "gdpr" {
  name             = "GDPR"
  database         = snowflake_database.terraform.name
  schema           = snowflake_schema.ENRICHED.name
  allowed_values   = ["personal", "sensitive"]
  masking_policies = [snowflake_masking_policy.personal_data.fully_qualified_name]
}

resource "snowflake_masking_policy" "first_name_only" {
  name     = "first_name_only"
  database = snowflake_database.terraform.name
  schema   = snowflake_schema.ENRICHED.name
  argument {
    name = "employee_name"
    type = "varchar"
  }
  body             = <<-EOP
 CASE
     WHEN CURRENT_ROLE() = '${snowflake_account_role.tf_data_engineer.name}' THEN employee_name
     ELSE 
       CASE
         WHEN POSITION(' ' IN employee_name) > 0 THEN 
           CONCAT(SUBSTRING(employee_name, 1, POSITION(' ' IN employee_name) - 1), ' ******')
         ELSE
           CONCAT(employee_name, ' ******')
       END
 END
EOP
  return_data_type = "varchar"
}

resource "snowflake_tag" "gdpr_partial" {
  name             = "GDPR_PARTIAL"
  database         = snowflake_database.terraform.name
  schema           = snowflake_schema.ENRICHED.name
  allowed_values   = ["personal"]
  masking_policies = [snowflake_masking_policy.first_name_only.fully_qualified_name]
}
