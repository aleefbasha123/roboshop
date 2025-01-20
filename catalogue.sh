#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
 
 MONGDB_HOST=mongodb.aleef.fun

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started    exceduing at $TIMESTAMP" &>> $LOGFILE
VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILED $N"
    else
        echo -e "$2...$G Success $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR:: Please run the script with root access"
    exit 1 #you can give other than 0
else
    echo "you are in root user"
fi #fi means reverse of if, including condtion end.

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "dISABLEING CURRENT NODEJS"

dnf module enable nodejs -y &>> $LOGFILE

VALIDATE $? "EABLEING NODEJS" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs"  

#useradd roboshp
VALIDATE $? "Creating Roboshop user" 

#mkdir /app
VALIDATE $? "Creating App Directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue application" 

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue application"  

npm install &>> $LOGFILE
VALIDATE $? "Installing dependences" 

#use absolute path beacuse catalogue exist there
cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon realod" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting  catalogue"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
 
VALIDATE $? "Installing mongodb-org-shell"


mongo --host $MONGDB_HOST </appa/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue data into mongodb"
