#!/bin/bash

email()
{ 
	email_addr="Wang Shilong <wangshilong1991@gmail.com>";
 	LANG=en_US.UTF8 mailx -t<<EOF
From: $email_addr
TO: $1
CC: $2
Subject: $3

$4
EOF
}

email "$1" "$2" "$3" "$4"

