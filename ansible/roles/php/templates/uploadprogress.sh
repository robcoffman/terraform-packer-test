#!/bin/bash

if [ -d "/usr/src/uploadprogress" ]; then
  echo "Upload progress php extnesion already installed"
else
  git clone https://github.com/Jan-E/uploadprogress /usr/src/uploadprogress
  cd /usr/src/uploadprogress
  phpize >> /var/log/uploadprogress_install.log
  ./configure >> /var/log/uploadprogress_install.log
  make >> /var/log/uploadprogress_install.log
  make install >> /var/log/uploadprogress_install.log
  echo "; configuration for php uploadprogress module" > /etc/php.d/uploadprogress.ini
  echo "; priority=20" >> /etc/php.d/uploadprogress.ini
  echo "extension=uploadprogress.so" >> /etc/php.d/uploadprogress.ini
fi
