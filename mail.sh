#!/bin/bash

email()
{ 
	email_addr="Wang Shilong <wangsl.fnst@cn.fujitsu.com>";
 	LANG=en_US.UTF8 mailx -t<<EOF
From: $email_addr
TO: $1
Subject: $2

$3 
EOF
}

email "$1" "$2" "$3"

