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


#Install applications
RUN apt-get -y install apache2
RUN apt-get -y install php libapache2-mod-php
RUN apt-get -y install phpmyadmin

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
