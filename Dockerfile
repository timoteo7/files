# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation
# Modification made by matthieu vallance<matthieu.vallance@cscfa.fr> to use php7.2

FROM eclipse/php

ENV DEBIAN_FRONTEND=noninteractive
ENV CHE_MYSQL_PASSWORD=che
ENV CHE_MYSQL_DB=che_db
ENV CHE_MYSQL_USER=che
ENV PHP_LS_VERSION=5.4.1

RUN sudo apt-get update && sudo apt-get install software-properties-common -y
RUN sudo add-apt-repository ppa:ondrej/php -y && sudo apt-get update

# install php with a set of most widely used extensions
RUN sudo apt-get update && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    php7.2 \
    php7.2-curl \
    php7.2-mysql \
    php7.2-gd \
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-cgi \
    php7.2-sqlite3 \
    php7.2-dom \
    php7.2-mbstring \
    php7.2-xml

RUN sudo sed -i 's/\/var\/www\/html/\/projects/g'  /etc/apache2/sites-available/000-default.conf && \
    sudo sed -i 's/\/var\/www/\/projects/g'  /etc/apache2/apache2.conf && \
    sudo sed -i 's/None/All/g' /etc/apache2/sites-available/000-default.conf && \
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf && \
    sudo a2enmod rewrite && \
    sudo service apache2 restart

# Install the Zend Debugger php module
RUN sudo wget http://repos.zend.com/zend-server/2018.0/deb_apache2.4/pool/zend-server-php-7.2-common_2018.0.3+b24_amd64.deb && \
    dpkg-deb --fsys-tarfile zend-server-php-7.2-common_2018.0.3+b24_amd64.deb | sudo tar -xf - --strip-components=7 ./usr/local/zend/lib/debugger/php-7.2.x/ZendDebugger.so && \
    sudo rm zend-server-php-7.2-common_2018.0.3+b24_amd64.deb && \
    sudo mv ZendDebugger.so /usr/lib/php/20170718 && \
    sudo sh -c 'echo "; configuration for php ZendDebugger module\n; priority=90\nzend_extension=ZendDebugger.so" > /etc/php/7.2/mods-available/zenddebugger.ini' && \
    sudo ln -s ../../mods-available/zenddebugger.ini /etc/php/7.2/cli/conf.d/90-zenddebugger.ini && \
    sudo ln -s ../../mods-available/zenddebugger.ini /etc/php/7.2/apache2/conf.d/90-zenddebugger.ini && \
    sudo sed -i 's/;opcache.enable=0/opcache.enable=0/g' /etc/php/7.2/apache2/php.ini && \
    sudo setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2 && \
    sudo chmod -R 777 /var/run/apache2 /var/lock/apache2 /var/log/apache2

RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer && \
    sudo chown -R user:users ~/.composer

EXPOSE 8080 8000
