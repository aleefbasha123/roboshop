#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "Copied Mongodb Repo"

dnf install mongodb-org -y  &&>> $LOGFILE

VALIDATE $? "Installing MonoDB"

systemctl enable mongod &&>> $LOGFILE

VALIDATE $? "Enabeling MonoDB"

systemctl start mongod &&>> $LOGFILE

VALIDATE $? "Strating MonoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &&>> $LOGFILE

VALIDATE $? "Remote access to Mongodb"

systemctl restart mongod &&>> $LOGFILE

VALIDATE $? "Restarting Mongodb"