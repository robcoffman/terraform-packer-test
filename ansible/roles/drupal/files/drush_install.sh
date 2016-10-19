#!/bin/bash

if [ -d "/usr/local/lib/drush" ]; then
  echo "Drush already installed"
else
git clone --branch master https://github.com/drush-ops/drush.git /usr/local/lib/drush
cd /usr/local/lib/drush && composer install
ln -s /usr/local/lib/drush/drush /usr/bin/drush

fi
