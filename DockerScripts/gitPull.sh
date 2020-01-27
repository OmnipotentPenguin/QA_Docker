#!/bin/bash

set_name () {
echo "Local copy name:"
read localName
check_for_spaces $localName
}

check_for_spaces () {
if [[ $localName =~ " " ]]; then
    echo 'Name cannot contain a space.'
    set_name
else
    echo 'ok'
    sudo git clone $gitURL $localName
    sudo mv $localName ~/GitRepoStore/$localName/
fi
}

echo "Git repo url:"
read gitURL
set_name

