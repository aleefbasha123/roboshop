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
        exit 1
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

VALIDATE $? "DISABLEING CURRENT NODEJS"

dnf module enable nodejs -y &>> $LOGFILE

VALIDATE $? "EABLEING NODEJS" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs"  

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
VALIDATE $? "Creating Roboshop user" 
else
   echo -e "roboshop user already existing $Y SKIPPING $N"
fi


mkdir -p /app
VALIDATE $? "Creating App Directory" 

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart application" 

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart application"  

npm install &>> $LOGFILE
VALIDATE $? "Installing dependences" 

#use absolute path beacuse cart exist there
cp /home/centos/roboshop/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon realod" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting  cart"

