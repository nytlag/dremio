#!/bin/bash

# This file will setup and configure community edition of the
# Dremio software on a remote EC2 server.

########## setup requirements ########
# Before running the test place the following files in the same directory
# 1. nytlag.sh (it is start up script )
# 2. remote.sh (it will be invoked on the remote host)
# 3. secruty key *.pem file
# 4. Add credentials and remote host details in


# provide login credentaion to the remote server

USER_NAME="<remote user name>"
host="<place host name>"
key="< *.pem file>"

#############
setup_file="remote.sh"

# function to track CTRL + xxx command
function trap_ctrlc ()
{
    echo
 	echo "$mylib1, trap_ctrlc, you pressed Ctrl-C... bye, exiting script"
 	echo
    cleanup_code

    # exit shell script with error code 2
    exit 2
}

# function to clean up the code
function cleanup_code()
{
        echo "cleaning up files before exit"

        ssh $USER_NAME"@"$host -i ./$key 'rm -rf ~/remote.sh dremio-community*.rpm'
        echo
        echo "Done, Thank you"
}

trap trap_ctrlc SIGINT


echo "=========================="
echo "copying setup script to the remote instance"
scp -i ./$key $setup_file $USER_NAME"@"$host":~"

echo "=========================="
echo "Installting Dremio"
ssh $USER_NAME"@"$host -i ./$key '~/remote.sh'

echo "=========================="
cleanup_code
