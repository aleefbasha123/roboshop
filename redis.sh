#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
 

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
VALIDATE $? "Dowloading Remi release"

dnf module enable redis:remi-6.2 -y  

VALIDATE $? "Enabling redis"

dnf install redis -y   

VALIDATE $? "Installing  redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf  

VALIDATE $? "Allowing Remote Access"

systemctl enable redis 

VALIDATE $? "Enabeling redis"

systemctl start redis  

VALIDATE $? "start redis"