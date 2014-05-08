#!/bin/sh

USER=$1
PASSWORD=$2
HOST=$3
DB=$4
DATE=`date +%Y%m%d`

mysqldump -u ${USER} -p${PASSWORD} -h ${HOST} ${DB} > ${DB}.${DATE}.dump
tar cfz ${DB}.${DATE}.dump.tgz ${DB}.${DATE}.dump
