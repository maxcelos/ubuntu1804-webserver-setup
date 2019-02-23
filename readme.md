# Ubuntu 18.04 WebServer Setup

A easy tool for configuring your web server.

## Programs

List of programs for installation

- admin users
- Composer
- Docker
- fail2ban
- hostname
- JAVA JRE
- JAVA SDK
- locale
- MySQL 8.0
- Nginx
- PHP7.2
    - php-fpm
    - php-mbstring
    - php-json
    - php-dom
    - php-gd
    - php-xml
- SSH
- UFW

## Configuration

For custom configuration, edit file `vars` for insert data for installation steps.

Where it will be defined:

- Hostname
- Instalation defaults
- Passwords
- SSH Port
- Sudoers
- UFW Allow
- Users

## Execution

Grant permission to file

`sudo chmod +x deploy.sh`

Run the file

`sudo ./deploy.sh`
