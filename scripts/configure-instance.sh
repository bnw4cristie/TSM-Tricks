#! /bin/bash

# check for beeing root
if [[ $USER != "root" ]]
then
  echo "Must be root to execute this script! -- Aborting"
  exit
fi

# check for server group and create if not already done
if [[ ! $(grep tsmsrvs /etc/group) ]]
then
  groupadd tsmsrvs -g 2000 
fi

# add user for instance
chown -R tsm09:tsmsrvs /tsm09
su -c "mkdir /tsm09/config" tsm09

useradd -d /tsm09 -u 2009 -g 2000 -s /bin/bash tsm09 
echo "tsm09:tsm09+PWD" | /sbin/chpasswd  

# create Db2 Database for TSM 
echo "creating database ..."
/opt/tivoli/tsm/db2/instance/db2icrt -a se/opt/tivoli/tsm/db2/instance/db2idrop tsm09rver -u tsm09 tsm09

if [[ $? ]]
then
  echo " ... successful :-)"
else
  echo " ... failed :-("
  echo "please issue '/opt/tivoli/tsm/db2/instance/db2idrop tsm09'"
  exit
fi
