#!/bin/bash

# Maxcelos web server setup

################################################
# Welcome Message
################################################
echo "################################################"
echo "Welcome to Maxcelos Server Setup!"
echo "################################################"

echo ""
printf "Did you change the variables? [y/n] "
read -r varSetup

if [ "$varSetup" != "y" ]
then
    echo ""
    echo "Please update the values on \"vars\" file before start"
    echo ""
    echo "Bye!"
    exit
fi


################################################
# End - Welcome Message
################################################


################################################
# Basic Server Setup
################################################
apt update && apt upgrade -y

source vars

locale-gen $LOCALE

timedatectl set-timezone $TIMEZONE

apt update

# Set Hostname
hostnamectl set-hostname $HOSTNAME
################################################
# End - Basic Server Setup
################################################


################################################
# Users and Admins setup
################################################
# Create users
i=0;
for user in "${USERS[@]}"
do
    useradd -m $user -s /bin/bash
    echo -e "${PASSWORDS[${i}]}\n${PASSWORDS[${i}]}\n" | passwd $user
    i=$((i+1));
done

# Add users to SUDO group
for superuser in "${SUDOERS[@]}"
do
    usermod -aG sudo $superuser
done
################################################
# End - Users and Admins setup
################################################


################################################
# Nginx Installation
################################################
if [ "$INSTALL_NGINX" = "y" ]
then
    ## Remove apache
    service apache2 stop
    apt purge apache* -y
    apt autoremove -y
    rm -Rf /etc/apache2 /usr/sbin/apache2 /usr/lib/apache2 /etc/apache2 /usr/share/apache2 /usr/share/man/man8/apache2.8.gz

    # Install Nginx
    apt install nginx -y

    echo "################################################"
    echo "Nginx Installed"
    echo "################################################"
fi
################################################
# End - Nginx Installation
################################################


################################################
# MySql8.0 Installation
################################################
if [ "$INSTALL_MYSQL8" = "y" ]
then
    # Install Mysql 8.0
    wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb

    dpkg -i mysql-apt-config_0.8.10-1_all.deb

    apt update

    apt install mysql-server -y

    # Secure MySql Installation
    mysql_secure_installation

    # DBA Account setup
    echo "Please enter root user MySQL password: "
    stty -echo
    read rootpasswd
    stty echo

    i=0;
    for superuser in "${SUDOERS[@]}"
    do
        
        mysql -uroot -p${rootpasswd} -e "CREATE USER '${superuser}'@'%' IDENTIFIED BY '${PASSWORDS[${i}]}';"
        mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON *.* TO '${superuser}'@'%';"
        mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
        i=$((i+1));
    done

    echo "################################################"
    echo "MySql8 Installed"
    echo "################################################"
fi
################################################
# End - MySql8.0 Installation
################################################


################################################
# UFW Setup
################################################
# Update UFW rules
ufw allow ssh
ufw allow $SSH_PORT

for rule in "${UFW_ALLOW[@]}"
do
    ufw allow $rule
done

ufw enable
################################################
# End - UFW Setup
################################################


################################################
# SSH Setup Update
################################################
# Update sshd setup
sed -i 's/#Port 22/Port '"${SSH_PORT}"'/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config



service ssh restart
################################################
# End - SSH Setup Update
################################################


################################################
# Fail2ban Installation
################################################
# Install and Setup Fail2Ban
apt install fail2ban -y

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

sed -i 's/port    = ssh/port    = '"${SSH_PORT}"'/g' /etc/fail2ban/jail.local
################################################
# End - Fail2ban Installation
################################################


################################################
# Docker Installation
################################################
if [ "$INSTALL_DOCKER" = "y" ]
then
    # Install Docker 
    apt install apt-transport-https ca-certificates curl software-properties-common -y

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

    apt update

    apt install docker-ce -y

    # Add users to DOCKER group
    for superuser in "${SUDOERS[@]}"
    do
        usermod -aG docker $superuser
    done

    # Install Docker Compose
    curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose


    echo "################################################"
    echo "Docker Installed"
    echo "################################################"
fi
################################################
# End - Docker Installation
################################################


################################################
# PHP7.2 Installation
################################################
if [ "$INSTALL_PHP72" = "y" ]
then
    apt install php-fpm -y
    apt install php-mbstring -y
    apt install php-json -y
    apt install php-dom -y
    apt install php-gd -y
    apt install php-xml -y


#    sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php/7.2/fpm/pool.d/www.conf
#    sed -i 's/pm.start_servers = 2/pm.start_servers = 7/g' /etc/php/7.2/fpm/pool.d/www.conf
#    sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/g' /etc/php/7.2/fpm/pool.d/www.conf
#    sed -i 's/pm.max_spare_servers = 3/pm.min_spare_servers = 10/g' /etc/php/7.2/fpm/pool.d/www.conf
#    sed -i 's/;pm.max_requests = 500/pm.max_requests = 500/g' /etc/php/7.2/fpm/pool.d/www.conf
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini


    echo "################################################"
    echo "PHP Installed"
    echo "################################################"
fi
################################################
# End - PHP7.2 Installation
################################################


################################################
# Composer Installation
################################################
if [ "$INSTALL_COMPOSER" = "y" ]
then
    # Instalação do composer
    php -r "readfile('https://getcomposer.org/installer');" | php
    mv composer.phar /usr/bin/composer
fi
################################################
# End - Composer Installation
################################################


################################################
# JAVA JRE Installation
################################################
if [ "$INSTALL_JAVA_JRE" = "y" ]
then
    apt install default-jre -y
fi
################################################
# End - JAVA JRE Installation
################################################


################################################
# JAVA SDK Installation
################################################
if [ "$INSTALL_JAVA_SDK" = "y" ]
then
    apt install default-jdk -y
fi
################################################
# End - JAVA SDK Installation
################################################


echo "################################################"
echo "################################################"
echo "Installation Done"
echo "################################################"
echo "################################################"

################################################
# Reboot Server
################################################

echo "Reboot now? [y/n] "
read rebootAction

if [ "$rebootAction" = "y" ]
then
    echo "Restarting the server..."
    echo "Bye!"
    reboot now
fi
