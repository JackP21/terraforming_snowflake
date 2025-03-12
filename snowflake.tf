resource "snowflake_database" "db" {
  name = "TERRAFORM"
}

resource "snowflake_warehouse" "warehouse" {
  name           = "TF_DATA_ENGINEER_WH"
  warehouse_size = "XSMALL"
  warehouse_type = "STANDARD"
  auto_suspend   = 30
}

# create resource for the role tf_data_engineer
# rename resource names
# create tf_data_analyst


# resource "snowflake_grant_privileges_to_account_role" "database_grant" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.role.name

#   on_account_object {
#     object_type = "DATABASE"
#     object_name = snowflake_database.db.name
#   }
# }

resource "snowflake_schema" "ACQUIRED" {
  database = snowflake_database.db.name
  name     = "ACQUIRED"
}

resource "snowflake_schema" "INGESTED" {
  database = snowflake_database.db.name
  name     = "INGESTED"
}

resource "snowflake_schema" "ENRICHED" {
  database = snowflake_database.db.name
  name     = "ENRICHED"
}

resource "snowflake_schema" "PRESENTED" {
  database = snowflake_database.db.name
  name     = "PRESENTED"
}

# resource "snowflake_grant_privileges_to_account_role" "schema_grant_acquired" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.role.name
#   on_schema {
#     schema_name = snowflake_schema.ACQUIRED.fully_qualified_name
#   }
# }

# resource "snowflake_grant_privileges_to_account_role" "schema_grant_ingested" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.tf_data_engineer.name
#   on_schema {
#     schema_name = snowflake_schema.INGESTED.fully_qualified_name
#   }
# }

# resource "snowflake_grant_privileges_to_account_role" "schema_grant_enriched" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.role.name
#   on_schema {
#     schema_name = snowflake_schema.ENRICHED.fully_qualified_name
#   }
# }

# resource "snowflake_grant_privileges_to_account_role" "schema_grant_presented" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.role.name
#   on_schema {
#     schema_name = snowflake_schema.PRESENTED.fully_qualified_name
#   }
# }

resource "snowflake_stage" "example_stage" {
  name        = "ACQUIRED"
  database    = snowflake_database.db.name
  schema      = snowflake_schema.ACQUIRED.name
}

resource "snowflake_file_format" "example_file_format" {

  name        = "CSV_WITH_HEADER"
  database    = snowflake_database.db.name
  schema      = snowflake_schema.ACQUIRED.name
  format_type = "CSV"
  skip_header = 1
  null_if     = ["NULL", "null"]
  date_format = "DD-MM-YYYY"  # Corrected date format
  field_optionally_enclosed_by = "\""
}

resource "snowflake_table" "acquired_table1" {
  database = snowflake_database.db.name
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

resource "snowflake_table" "acquired_table2" {
  database = snowflake_database.db.name
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
    name = "COCK_IN"
    type = "TIME"
  }

  column {
    name = "CLOCK_OUT"
    type = "TIME"
  }
}

resource "snowflake_table" "acquired_table3" {
  database = snowflake_database.db.name
  schema   = snowflake_schema.ACQUIRED.name
  name     = "EMPLOYEES"
  
  column {
    name = "ID"
    type = "VARCHAR"
  }

  column {
    name = "role_name"
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

resource "snowflake_table" "acquired_table4" {
  database = snowflake_database.db.name
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

# resource "snowflake_grant_privileges_to_account_role" "warehouse_grant" {
#   provider          = snowflake.security_admin  
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_account_role.role.name
#   on_account_object {
#     object_type = "WAREHOUSE"
#     object_name = snowflake_warehouse.warehouse.name
#   }
# }
