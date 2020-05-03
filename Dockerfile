#Use the Ubuntu base image
FROM ubuntu

#Update all packages
RUN apt-get update

#Install tzdata and set timezone.
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y install tzdata

#Install Software Properties
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

#Install C/C++ Compiler
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update -y
RUN apt-get install -y gcc-4.8
RUN apt-get install -y g++-4.8
RUN ln -f -s /usr/bin/gcc-4.8 /usr/bin/gcc
RUN ln -f -s /usr/bin/g++-4.8 /usr/bin/g++

#Install Java Compiler
RUN add-apt-repository -y ppa:openjdk-r/ppa  
RUN apt-get update -y  
RUN apt install -y openjdk-8-jre
RUN apt-get install -y default-jdk

#Install applications
RUN apt-get -y install apache2
RUN apt-get -y install php libapache2-mod-php

#Remove any unnecessary files
RUN apt-get clean

#Setup Apache2 servers                                               
#Debian configuration requires the environment variables APACHE_RUN_USER, APACHE_RUN_GROUP, and APACHE_PID_FILE to be set
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid

#Expose ports
EXPOSE 80

#Start services
CMD /usr/sbin/apache2ctl -D FOREGROUND

#Copy files to webserver 
COPY myprojphp /var/www/html/

#Change Permission
RUN chmod -R 777 /var/www/html/

# Remove Default index.html
RUN rm /var/www/html/index.html

RUN sudo apt-get --purge remove mysql-server mysql-common mysql-client.

RUN sudo apt update && sudo apt dist-upgrade && sudo apt autoremove.

RUN sudo apt-get install -y mysql-server mysql-client.

RUN mysql -u [root] -p mobile < https://github.com/ShakthiMudaliar/myprojphp/mobile.sql
# Create dir for database data  
RUN mkdir -p /opt/mysql


# Create MySQL container 
RUN docker run -d \
    --name mobile-mysql \
    --network mobile \
    -e MYSQL_ROOT_PASSWORD="" \
    -v /opt/mysql:/var/lib/mysql \
    -p 3306:3306 \
    mysql:8.0.12
# Create phpMyAdmin container
# 
# PMA_HOST is the IP or domain of the MySQL server,
# so we can use the MySQL container name as the domain
# cause the Docker network create the route as a DNS server.
RUN docker run -d \
    --name mobile-phpmyadmin \
    --network mobile \
    -e PMA_HOST=mobile-mysql \
    -p 8080:80 \
    phpmyadmin/phpmyadmin:edge
