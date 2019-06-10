# reveal_scan_id_match.R

# Load Libraries

suppressMessages( library(dplyr) )
suppressMessages( library(readr) )
suppressMessages( library(readxl) )
suppressMessages( library(stringr) )


# Load Useful Globals/Functions

source("~/Box Sync/Documents/R_helpers/config.R")
source("~/Box Sync/Documents/R_helpers/helpers.R")


# Load Data

# _ REVEAL-SCAN Spreadsheets

df_rs_pts <- read_excel( 
  paste0(
    "./",
    "input_spreadsheets/",
    "List of REVEAL-SCAN Participants Completed 20190607.xlsx"
  ),
  range = "A1:G65")

df_rs_amy <- read_excel(
  paste0(
    "./",
    "input_spreadsheets/",
    "REVEAL-SCAN Study Completed Participants Amyloid Status 20190607.xlsx"
  ))

# _ UM-MAP Data

fields_u3_raw <-
  c(
    "ptid"
    , "form_date"
    , "mrn"
  )

fields_u3 <- fields_u3_raw %>% paste(collapse = ",")

json_u3 <- get_rc_data_api(uri = REDCAP_API_URI,
                           token = REDCAP_API_TOKEN_UDS3n,
                           fields = fields_u3)
df_u3 <- jsonlite::fromJSON(json_u3) %>% as_tibble() %>% na_if("")


# Process Data

# _ Clean Data

df_u3_cln <- 
  df_u3 %>% 
  select(-redcap_event_name) %>% 
  filter(str_detect(ptid, "^UM\\d{8}$")) %>% 
  filter(!is.na(form_date)) %>% 
  get_visit_n(id_field = ptid, date_field = form_date, Inf)


# _ Join Data

df_rs_pts_u3 <-
  left_join(df_rs_pts, df_u3_cln, by = c("MRN" = "mrn"))

df_rs_amy_u3 <-
  left_join(df_rs_amy, df_u3_cln, by = c("MRN" = "mrn"))


# Write CSVs

write_csv(
  df_rs_pts_u3,
  paste0("./",
         "output_spreadsheets/",
         "REVEAL-SCAN_pts_with_UMMAP_ID.csv"),
  na = "")

write_csv(
  df_rs_amy_u3,
  paste0("./",
         "output_spreadsheets/",
         "REVEAL-SCAN_amyloid_with_UMMAP_ID.csv"),
  na = "")
















