#!/bin/bash

set_port () {
echo "Port connection:"
read port
re='^[0-9]+$'
if ! [[ $port =~ $re ]] ; then
   echo "Error: Not a number" >&2;
   set_port
else
   echo "Port set to $port:$port"
   set_name
fi
}


set_name () {
echo "Build name:"
read regName
if [[ $regName =~ " " ]]; then
    echo 'Name cannot contain a space.'
    set_name
else
    echo "Name set to $regName"
    set_image
fi
}


set_image () {
echo "Image name:"
read imageName
if [[ $imageName =~ " " ]]; then
    echo 'Name cannot contain a space.'
    set_image
else
    echo 'ok'
    is_database
fi
}


is_database () {
echo "Are you building a mysql database? (y/n)"
read answer
case $answer in
	"y"|"Y")
		echo "Databse password set to root"
		docker run -p $port:3306 --name $regName -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
		;;
	"n"|"N")
		docker run -d -p $port:$port --name $regName $imageName
		;;
	*)
		echo "Invalid answer"
		is_database
		;;
esac
}

set_port

