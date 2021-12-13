#!/bin/bash

#   Execute this script from your HOST machine 
#   if the docker volume directory permissions 
#   are messed up (e.g. after migrating to another host machine).

sudo docker exec -it svn-server chown -R www-data:subversion /home/svn
sudo docker exec -it svn-server chmod -R 770 /home/svn
