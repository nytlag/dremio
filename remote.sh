#!/bin/bash

fname="dremio-community-20.1.0-202202061055110045_36733c65_1.noarch.rpm"
URL="http://download.dremio.com/community-server/20.1.0-202202061055110045-36733c65/dremio-community-20.1.0-202202061055110045_36733c65_1.noarch.rpm"

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

echo `hostname`

echo "=========================="
echo "installing jdk "
echo "=========================="
sudo yum -y install java-1.8.0-openjdk

java -version

echo "=========================="
echo "downloading installation package "
echo "=========================="

sudo wget $URL

check_downloaded_file


sudo yum -y install dremio-community-20.1.0-202202061055110045_36733c65_1.noarch.rpm


sudo service dremio start

echo "=========================="
sudo service dremio status
echo "=========================="
