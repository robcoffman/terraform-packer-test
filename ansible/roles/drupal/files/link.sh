#!/bin/bash

#rm -rf /var/www/public_html/sites/default/settings.php
#ln -s /var/www/config/dev.settings.php /var/www/public_html/sites/default/settings.php

rm -rf /usr/bin/refresh_db
ln -s /usr/local/bin/refresh_db.sh /usr/bin/refresh_db

rm -rf /usr/bin/importdb
ln -s /usr/local/bin/import_db.sh /usr/bin/importdb
