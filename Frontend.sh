#!/bin/bash
# set -e

ID=$(id -u)
if [ "$ID" -ne 0 ] ; then
   echo -e "Please execute though root user"
   exit 1
fi
echo -n "Installing Nginx : "
yum install nginx -y &>> /tmp/frontend.log

if [ $? -eq 0 ] ; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure  \e[0m"
    exit 2
fi
echo -n "Downloading the frontend component : "
curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"

if [ $? -eq 0 ] ; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure  \e[0m"
    exit 2
fi
echo -n "Performing cleanup of old frontend content : " 
cd /usr/share/nginx/html
rm -rf * &>> /tmp/frontend.log

if [ $? -eq 0 ] ; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure  \e[0m"
    exit 2
fi
echo "Copying the downloaded frontend content : "
unzip /tmp/frontend.zip &>> /tmp/frontend.log
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

if [ $? -eq 0 ] ; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure  \e[0m"
    exit 2
fi
echo -n "Starting the service : "
systemctl enable nginx &>> /tmp/frontend.log
systemctl restart nginx &>> /tmp/frontend.log

if [ $? -eq 0 ] ; then
    echo -e "\e[32m Success \e[0m"
else
    echo -e "\e[31m Failure  \e[0m"
    exit 2
fi

