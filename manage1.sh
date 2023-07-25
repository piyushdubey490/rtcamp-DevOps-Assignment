#!/bin/zsh

# Function to check if a command is available
check_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Docker and Docker Compose if not already present
install_docker_and_compose() {
    if ! check_exists docker || ! check_exists docker-compose; then
        echo "Docker and/or Docker Compose not found. Installing..."
        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker

        # Install Docker Compose
        sudo apt-get install -y docker-compose
        echo "Docker and Docker Compose have been installed successfully."
    else
        echo "Docker and Docker Compose are already installed."
    fi
}

# Function to create the WordPress site using Docker Compose
create_wordpress_site() {
    if [ -z "$1" ]; then
        echo "Please provide the site name as an argument."
        exit 1
    fi

    SITE_NAME="$1"
    echo "Creating WordPress site: $SITE_NAME"

    # Set up the Docker Compose file
    cat <<EOF >docker-compose.yml
version: "3"
services:
  webserver:
    image: wordpress:latest
    container_name: ${SITE_NAME}_webserver
    ports:
      - "8081:80"
    volumes:
      - "./wordpress:/var/www/html"
      - "./nginx-config:/etc/nginx/sites-available"
      - "./nginx-config:/etc/nginx/sites-enabled"
    networks:
      - ${SITE_NAME}_wp_network

  php:
    image: php:7.2-fpm
    container_name: ${SITE_NAME}_php
    volumes:
      - "./wordpress:/var/www/html"
    networks:
      - ${SITE_NAME}_wp_network

  db:
    image: mysql:latest
    container_name: ${SITE_NAME}_db
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: ${SITE_NAME}_wordpress
      MYSQL_USER: ${SITE_NAME}_wordpress
      MYSQL_PASSWORD: ${SITE_NAME}_password
    volumes:
      - "./db-data:/var/lib/mysql"
    networks:
      - ${SITE_NAME}_wp_network

networks:
  ${SITE_NAME}_wp_network:
    driver: bridge
EOF

    # Create necessary directories
    mkdir -p wordpress nginx-config db-data

    # Create /etc/hosts entry
    sudo -- sh -c "echo '127.0.0.1 $SITE_NAME' >> /etc/hosts"

    # Start containers
    docker-compose up -d

    echo "WordPress site '$SITE_NAME' has been created and is accessible at $SITE_NAME."
    echo "Please open $SITE_NAME in your browser to complete the setup."
}

# Function to stop or start the WordPress site
site_control() {
    if [ -z "$1" ]; then
        echo "Please provide the action (start/stop) as an argument."
        exit 1
    fi

    ACTION="$1"

    case "$ACTION" in
    start)
        docker-compose start
        echo "WordPress site started."
        ;;
    stop)
        docker-compose stop
        echo "WordPress site stopped."
        ;;
    *)
        echo "Invalid action. Use 'start' or 'stop'."
        exit 1
        ;;
    esac
}

# Function to delete the WordPress site
delete_wordpress_site() {
    echo "Stopping and removing containers..."
    docker-compose down

    echo "Deleting local files..."
    rm -rf wordpress nginx-config db-data

    SITE_NAME=$(grep -oP '127.0.0.2 \K.*' /etc/hosts)
    if [ -n "$SITE_NAME" ]; then
        sudo sed -i "/$SITE_NAME/d" /etc/hosts
    fi

    echo "WordPress site has been deleted."
}

# Check for Docker and Docker Compose, and install if missing
install_docker_and_compose

# Parse subcommands and execute corresponding functions
case "$1" in
create)
    create_wordpress_site "$2"
    ;;
control)
    site_control "$2"
    ;;
delete)
    delete_wordpress_site
    ;;
*)
    echo "Usage: $0 create <site_name> | control <start/stop> | delete"
    exit 1
    ;;
esac
