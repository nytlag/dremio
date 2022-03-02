#!/bin/bash
# This remote.sh file will be copied onto a remote instance and dremio setup.
# It will download dremio-community-20.1.0 CE package. To download different package,
# change fname=<value> to a desired package

fname="dremio-community-20.1.0-202202061055110045_36733c65_1.noarch.rpm"
URL="http://download.dremio.com/community-server/20.1.0-202202061055110045-36733c65/"$fname

function check_downloaded_file()
{
	found=0
	echo "=========================="
  echo "checking to see if file was downloaded"
  echo "=========================="
	for f in * ; do

		if ([ "$f" = "$fname" ])
		then
				echo "file found $f"
				found=1
				break
		fi
	done
	[ $found -ne 1 ] && echo "$fname was not downloaded"

}

# function tot track CTRL + xxx command
function trap_ctrlc ()
{
    echo "trap_ctrlc, you pressed Ctrl-C... bye, exiting script"
    # exit shell script with error code 2
    exit 2
}



trap trap_ctrlc SIGINT

echo `hostname`

echo "=========================="
echo "installing jdk "
echo "=========================="
sudo yum -y install java-1.8.0-openjdk

java -version

echo "=========================="
echo "downloading dremio installation package "
echo "=========================="

sudo wget $URL

check_downloaded_file

echo "=========================="
echo "installting Dremio rpm package"
echo "=========================="
sudo yum -y install dremio-community-20.1.0-202202061055110045_36733c65_1.noarch.rpm


sudo service dremio start

echo "=========================="
# sudo service dremio status
# echo "=========================="
