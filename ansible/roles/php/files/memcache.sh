#!/bin/bash

if [ -d "/usr/src/php-memcached" ]; then
  echo "Memcache php extnesion already installed"
else
  git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php-memcached
  cd /usr/src/php-memcached
  git checkout -b php7 origin/php7
  phpize >> /var/log/memcache_install.log
  ./configure --with-php-config=/usr/bin/php-config  >> /var/log/memcache_install.log
  make >> /var/log/memcache_install.log
  make install >> /var/log/memcache_install.log

  echo ";Memcached" > /etc/php.d/memcache.ini
  echo "extension=memcached.so" >> /etc/php.d/memcache.ini
fi
