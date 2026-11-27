-- Run with psql; app_password is passed on the command line (see below).
CREATE USER sme_app WITH PASSWORD :'app_password';

CREATE DATABASE user_db         OWNER sme_app;
CREATE DATABASE invoice_db      OWNER sme_app;
CREATE DATABASE openbanking_db  OWNER sme_app;
CREATE DATABASE creditrisk_db   OWNER sme_app;
CREATE DATABASE financing_db    OWNER sme_app;
CREATE DATABASE bidding_db      OWNER sme_app;
CREATE DATABASE payment_db      OWNER sme_app;
CREATE DATABASE notification_db OWNER sme_app;
CREATE DATABASE admin_db        OWNER sme_app;