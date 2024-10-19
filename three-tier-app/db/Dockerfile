# Use the official MySQL image
FROM mysql:latest

# Copy the initialization script to the Docker entrypoint directory
COPY schema.sql /docker-entrypoint-initdb.d/

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=tecvinson_registration

# Expose MySQL port
EXPOSE 3306
