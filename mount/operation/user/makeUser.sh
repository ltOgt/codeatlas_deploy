#!/bin/bash

# functions
function print_usage ()
{
	echo 'USAGE: ./makeUser.sh <username> <group>'
	echo "  <username>    may only contain letters and numbers"
	echo "  <group> == 0  => CONTROL"
	echo "  <group> == 1  => CANVAS"
}

if [[ $1 == "-h" || $1 == "--help" ]]; then
	print_usage
	exit 0
fi

if [[ $# -ne 2 ]]; then
	print_usage
	exit 1
fi

username=$1
group=$2

if ! [[ $username =~ ^[a-zA-Z0-9]+$ ]]; then
	echo "username does not match requirements:"
	print_usage
	exit 1
fi

if [[ $group -ne 0 && $group -ne 1 ]]; then
	echo "group does not match requirements:"
	print_usage
	exit 1
fi

function create () {
	mkdir "$1" || exit 1
	echo "Created $1 ..."
	echo "( Will store $2 )"
	echo ""
}

mkdir "$1" || exit 1

create "$1/brunnr" "Canvas Data"
create "$1/intend" "User Actions"
create "$1/log" "Server Websocket Requests"
create "$1/task" "Solutions to Tasks"

if [[ $group -eq 0 ]]; then
	touch "$1/.ctrl"
	echo "Created $1/.ctrl to designate control group"
else
	echo "Absence of $1/.ctrl designates canvas group"
fi

echo ""
echo "OK! user creation completed"
exit 0

