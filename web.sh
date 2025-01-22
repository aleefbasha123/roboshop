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

dnf install ngnix &>> $LOGFILE

VALIDATE $? "INSTALLING NGINX"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "ENAVLEING NGINX"

systemctl start nginx  &>> $LOGFILE

VALIDATE $? "STARTING NGINX"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "removing default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>> $LOGFILE

VALIDATE $? "Downloading web content"

cd /usr/share/nginx/html  &>> $LOGFILE

VALIDATE $? "Goining html folder"

unzip -o /tmp/web.zip  &>> $LOGFILE

VALIDATE $? "Unziping web content"

cp /home/centos/roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "robosho config"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restating nginx"

