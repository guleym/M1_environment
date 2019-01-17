FROM mariadb:10.2

# when a container is started for the first time, a new database with the specified name will be created and
# initialized with the provided configuration variables. Furthermore, it will execute files with extensions
# .sh | .sql. | .sql.qz that are found in /docker-entrypoint-initdb.d
# Files will be executed in alphabetical order.

# DB deployment
ADD db_dump.sql /docker-entrypoint-initdb.d
# URL replacement, 'core_config_data' table
ADD url_replacement.sql /docker-entrypoint-initdb.d