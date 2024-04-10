#! /bin/bash

# check for beeing root
if [[ $USER != "root" ]]
then
  echo "Must be root to execute this script! -- Aborting"
  exit
fi

# create TSMDB1 
echo "creating database ..."
/opt/tivoli/tsm/db2/instance/db2icrt -a server -u tsm02 tsm02

if [[ $? ]]
then
  echo " ... successful :-)"
else
  echo " ... failed :-("
  echo "please issue ..."
  exit
fi
