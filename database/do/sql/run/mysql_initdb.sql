CREATE DATABASE myjourney_wpdb;

CREATE DATABASE metabase_db;

CREATE USER 'us_wordpress'@'%' IDENTIFIED BY 'W0rdpr3ss-2020!';
GRANT ALL PRIVILEGES ON myjourney_wpdb.* TO 'us_wordpress'@'%';

CREATE USER 'usr_metabase_db' @'%' IDENTIFIED BY 'F1mxLllGmtvM68AT';
GRANT ALL PRIVILEGES ON metabase_db.* TO 'usr_metabase_db' @'%';