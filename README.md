# rtcamp-DevOps-Assignment

# WordPress Docker Setup

This repository contains a shell script (`wordpress_docker_setup.sh`) that helps you quickly set up a WordPress site using Docker and Docker Compose. The script simplifies the installation and configuration process, allowing you to focus on building your WordPress site. Below, you'll find instructions on how to use the script effectively.

## Prerequisites

Before running the script, ensure you have the following prerequisites:

1. NIX-based operating system (tested on MacOS)
2. [Docker](https://www.docker.com/) installed
3. [Docker Compose](https://docs.docker.com/compose/) installed

## Getting Started

1. Clone this repository to your local machine:

```zsh
git clone https://github.com/your-username/wordpress-docker-setup.git
cd wordpress-docker-setup
```
2.  Make the Script Executable giving permissions
```zsh
chmod +x wordpress_docker_setup.sh
```

Usage

## The script supports three main commands:

1. Create a WordPress site:
To create a new WordPress site, use the following command:

```zsh
./wordpress_docker_setup.sh create <site_name>
```
Replace <site_name> with the desired name for your WordPress site. The script will automatically set up containers for the webserver, PHP, and database.

2. Control the WordPress site:
To start or stop an existing WordPress site, use the following command:

```zsh
./wordpress_docker_setup.sh control <start/stop>
```
Replace <start/stop> with either "start" to start the containers or "stop" to stop them.

3. Delete a WordPress site:
To delete an existing WordPress site and all associated containers and files, use the following command:

```zsh
./wordpress_docker_setup.sh delete
```


## Note
Docker and Docker Compose are not already installed, the script will attempt to install them for you using apt-get. Ensure that you have sufficient permissions to run apt-get with sudo.
The script will add an entry to your /etc/hosts file to map 127.0.0.1 to your WordPress site's URL. This allows you to access the site in your browser locally.

