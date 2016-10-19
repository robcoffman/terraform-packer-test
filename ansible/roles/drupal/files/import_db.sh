#!/bin/bash

#cleanup
  rm -rf /tmp/db/*.gz;

#Downloading Db
  echo "Downloading DB";
  today=`aws s3 ls s3://ebco-backup/ebco_dbbackup/ | sort -n -r | head -1 | awk '{print $4}'`;
  aws s3 cp "s3://ebco-backup/ebco_dbbackup/$today" /tmp/db/;
  mv /tmp/db/$today /tmp/db/homepage_sql.gz;

# Drop Database
  echo "Dropping Tables";
  drush_sql=`drush @vagrant.homepage sql-connect | awk '{print  $1,$2,$3,$5,$6}'`;
  drush_sql_create=" -e 'create database vagrant;'";
  drush_sql_drop=" -e 'drop database vagrant;'";
  eval $drush_sql $drush_sql_drop;
  eval $drush_sql $drush_sql_create;


#Import Database
  echo "Importing database snapshot";
  cd /var/www/public_html;
  pv /tmp/db/homepage_sql.gz | gunzip | eval `drush @vagrant.homepage sql-connect`;

#Site files
echo "Syncing Site Files"
  aws s3 sync s3://ebco-backup/ebco_files /var/www/public_html/sites/default/files
  chown -R vagrant:vagrant /var/www/public_html/sites/default/files

#cache
  drush @vagrant.homepage cache-rebuild

#Enable non-prod modules
  #drush en rhc4tp_devel -y || return $?
