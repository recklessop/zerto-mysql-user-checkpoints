#!/bin/sh
#pre-freeze-script

date >> '/scripts/pre_root.log'

echo -e "\n attempting to run pre-freeze script for MySQL as root user\n" >> /scripts/pre_root.log

sudo -H python '/scripts/quiesce.py' &

echo -e "\n executing query flush tables with read lock to quiesce the database\n" >> /scripts/pre-freeze.log

echo -e "\n Database is in quiesce mode now\n" >> /scripts/pre-freeze.log
