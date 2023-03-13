#!/bin/bash
COMPONENT=catalogue
LOGFILE=" /tmp/$COMPONENT.log"
APPUSER=roboshop
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
echo -n  "Configuring the node js repo : "
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - &>> $LOGFILE
stat $?

echo -n "Installing node JS : "
yum install nodejs -y &>> $LOGFILE
stat $?

echo -n "Creating the application user account : "
useradd $COMPONENT &>> $LOGFILE
stat $?

echo -n "Downloading the $COMPONENT components : "
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "Extracting the $COMPONENT in the $APPUSER directory : "
cd /home/$APPUSER
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

