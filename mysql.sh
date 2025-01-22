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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "old version disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "coping  mysql-repo"

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enable  mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "start  mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "set root password"
mysql -uroot -pRoboShop@1 &>> $LOGFILE
VALIDATE $? "user root"



