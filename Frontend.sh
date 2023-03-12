#!/bin/bash
# set -e
COMPONENT=frontend
LOGFILE=" /tmp/$COMPONENT.log"
ID=$(id -u)
if [ "$ID" -ne 0 ] ; then
   echo -e "Please execute though root user"
   exit 1
fi

stat(){
    if [ $? -eq 0 ] ; then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m Failure  \e[0m"
        exit 2
    fi   
}
echo -n "Installing Nginx : "
yum install nginx -y &>> $LOGFILE
stat $?

echo -n "Downloading the $COMPONENT component : "
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"

stat $?
echo -n "Performing cleanup of old $COMPONENT content : " 
cd /usr/share/nginx/html
rm -rf * &>> $LOGFILE

stat $?
echo -n "Copying the downloaded $COMPONENT content : "
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
mv $COMPONENT-main/* .
mv static/* .
rm -rf $COMPONENT-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

stat $?
echo -n "Starting the service : "
systemctl enable nginx &>> $LOGFILE
systemctl restart nginx &>> $LOGFILE

stat $?

