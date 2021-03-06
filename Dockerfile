FROM php:5.6-cli
WORKDIR /usr/src/myapp/KeleiDMS
RUN set -xe \
# "构建依赖"
    && buildDeps=" \
        git \
        build-essential \
        php5-dev \
        php5-mysql \
	php5-xmlrpc \
	libxml2 \
	libxml2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpcre3-dev \
    " \
# "安装 php 以及编译构建组件所需包"
    && groupadd www \
    && useradd -s /sbin/nologin -g www www \
    && apt-get update \
    && apt-get install -y ${buildDeps} --no-install-recommends \
    && pecl install swoole \
# "编译安装 php 组件"
    && docker-php-ext-install iconv mcrypt mysqli pdo pdo_mysql zip soap sockets xmlrpc \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
  # 编译、安装 phalcon
    && git clone --depth=1 git://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build \
    && ./install \
    && cd ../.. \
    && rm -rf cphalcon \
 # 编译安装 swoole 
    && git clone -b 2.0.1 https://github.com/swoole/swoole-src.git \
    && cd swoole-src \
    && phpize \ 
    && ./configure \
    && make && make install \
    && cd ../.. \
    && rm -rf swoole-src \
    && docker-php-ext-enable phalcon soap sockets xmlrpc swoole
EXPOSE 23456
CMD [ "php", "./apps/consoles/cli.php", "main", "swoole", "wait" ]
