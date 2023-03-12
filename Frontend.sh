#!/bin/bash
set -e

ID=$(id -u)
if [ "$ID" -ne 0 ] ; then
   echo -e "Please execute though root user"
   exit 1
fi

yum install nginx -y &>> /tmp/frontend.log


curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"

cd /usr/share/nginx/html
rm -rf * &>> /tmp/frontend.log
unzip /tmp/frontend.zip &>> /tmp/frontend.log
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

systemctl enable nginx &>> /tmp/frontend.log
systemctl restart nginx &>> /tmp/frontend.log


