FROM ubuntu:18.04
ENV TERM linux
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Fortaleza

RUN apt-get update
RUN apt-get remove --purge php5* && apt-get autoremove
RUN apt-get install -y apt-transport-https ca-certificates \
 && apt-get install -y language-pack-en-base software-properties-common apt-utils

RUN apt-get install -y tzdata

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN apt-get install -y software-properties-common \
 && apt-add-repository ppa:ondrej/php
RUN apt-get update

RUN apt-get install -y unzip apache2 libapache2-mod-php5.6 php5.6 php5.6-dev \
php5.6-cli php5.6-curl php5.6-fpm php5.6-json php5.6-mbstring php5.6-mcrypt \
php5.6-mysql php5.6-opcache php5.6-pgsql php5.6-readline php5.6-xml \
libsybdb5 freetds-common php5.6-sybase php5.6-gd \
 build-essential libaio1
RUN apt-get clean -y

ENV LD_LIBRARY_PATH /opt/oracle/instantclient_12_1
ENV ORACLE_HOME /opt/oracle/instantclient_12_1

# Oracle instantclient
ADD instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/ 
ADD instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/ 
ADD instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/ 
RUN mkdir /opt/oracle \
&& unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle/ \
&& unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle/ \
&& unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /opt/oracle/ \
&& rm -rf /tmp/*.zip \
&& ln -s /opt/oracle/instantclient_12_1 /opt/oracle/instantclient_12_1 \
&& ln -s /opt/oracle/instantclient_12_1/libclntsh.so.12.1 /opt/oracle/instantclient_12_1/libclntsh.so \
&& ln -s /opt/oracle/instantclient_12_1/sqlplus /usr/bin/sqlplus \
&& echo /opt/oracle/instantclient_12_1 > /etc/ld.so.conf.d/oracle-instantclient.conf \
&& echo 'instantclient,/opt/oracle/instantclient_12_1' | pecl install oci8-2.0.12 && echo "extension=oci8.so" >> /etc/php/5.6/cli/php.ini \
&& echo $LD_LIBRARY_PATH >> /etc/environment && echo $ORACLE_HOME >> /etc/environment 

RUN echo "<?php echo phpinfo(); ?>" > /var/www/html/index.php

WORKDIR /var/www/html/

CMD php -S 0.0.0.0:8888

EXPOSE 8888