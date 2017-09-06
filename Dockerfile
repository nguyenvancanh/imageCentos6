FROM centos:6

MAINTAINER Nguyen Van Canh <canhky92@gmail.com>

# Update yum

RUN yum -y update
RUN yum -y install yum-utils

# Install some must-haves

RUN yum -y groupinstall "Development Tools"
RUN yum -y install wget --nogpgcheck
RUN yum -y install vim --nogpgcheck

# Install remi repo

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

# Install php7

RUN \
    yum -y install \
        php71w \
        php71w-opcache \
        libaio-devel \
        php71w-pear \
        php71w-devel \
        php71w-mbstring \
        php71w-pdo

# Install Composer

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# Install Node & Yarn

ENV NODE_VERSION 7

RUN curl --silent --location https://rpm.nodesource.com/setup_$NODE_VERSION.x | bash - && \
    yum -y install nodejs bzip2 freetype-devel fontconfig-devel && \
    yum clean all && \
    npm install -g yarn --no-progress

# Install Apache

RUN yum -y update && \
    yum -y install httpd && \
    yum clean all

# Install oci8-driver

COPY ./oracle-client /tmp/oracle-client
RUN rpm -ivh /tmp/oracle-client/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN rpm -ivh /tmp/oracle-client/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
RUN rpm -ivh /tmp/oracle-client/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV PKG_CONFIG_PATH /oracle-client/

RUN echo 'instantclient,/usr/lib/oracle/12.1/client64/lib/' | pecl install oci8

EXPOSE 80 443

COPY run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh"]