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

useradd -d /tsm09 -u 2009 -g 2000 -s /bin/bash tsm09 
echo "tsm09:tsm09+PWD" | /sbin/chpasswd  

# create folders
chown root:tsmsrvs /actlog /archlog /archover /db01 /db02 /dbbackup /stgc /stgf 
chmod g+w /actlog /archlog /archover /db01 /db02 /dbbackup /stgc /stgf 

su -c "mkdir /tsm09/config"                                tsm09 
su -c "mkdir /db01/tsm09   /db02/tsm09    /dbbackup/tsm09" tsm09 
su -c "mkdir /actlog/tsm09 /archlog/tsm09 /archover/tsm09" tsm09 
su -c "mkdir /stgc/tsm09   /stgf/tsm09"                    tsm09 
su -c "mkdir /tsm09/srvmon"                                tsm09  


# create Db2 Database for TSM 
echo "creating database ..."
/opt/tivoli/tsm/db2/instance/db2icrt -a server -u tsm09 tsm09

if [[ $? ]]
then
  echo " ... successful :-)"
else
  echo " ... failed :-("
  echo "please issue '/opt/tivoli/tsm/db2/instance/db2idrop tsm09'"
  exit
fi

# prepare settings for instance user
echo "prepar user for using Db2" 
su -c 'echo "export LD_LIBRARY_PATH=/opt/tivoli/tsm/server/bin/dbbkapi:/usr/local/ibm/gsk8_64/lib64:/opt/ibm/lib:/opt/ibm/lib64:\$LD_LIBRARY_PATH" >> ~/sqllib/userprofile'          tsm09  
su -c 'echo "setenv LD_LIBRARY_PATH /opt/tivoli/tsm/server/bin/dbbkapi:/usr/local/ibm/gsk8_64/lib64:/opt/ibm/lib:/opt/ibm/lib64:/usr/lib64:\$LD_LIBRARY_PATH" >> ~/sqllib/usercshrc' tsm09  


# 
