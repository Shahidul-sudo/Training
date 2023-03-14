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
id $APPUSER &>> $LOGFILE
if [ $? -ne 0 ]; then
    echo -n "Creating the application user account : "
    useradd roboshop &>> $LOGFILE
    stat $?
fi

echo -n "Downloading the $COMPONENT components : "
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
stat $?

echo -n "Extracting the $COMPONENT in the $APPUSER directory : "
cd /home/$APPUSER
rm -rf /home/$APPUSER/$COMPONENT
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE
stat $?

echo -n "Configuring the permissions : "
mv /home/$APPUSER/$COMPONENT-main /home/$APPUSER/$COMPONENT
chown -R $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT
stat $?

echo -n "Installing the $COMPONENT Application : "
cd /home/roboshop/$COMPONENT/
npm install &>> $LOGFILE
stat $?

echo -n "Updating the systemd file with DB details : "
sed -i -e  's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
stat $?

echo -n "Starting the $COMPONENT service : "
systemctl daemon-reload
systemctl start $COMPONENT &>> $LOGFILE
systemctl enable $COMPONENT &>> $LOGFILE
systemctl status $COMPONENT -l &>> $LOGFILE
stat $?