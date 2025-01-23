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
fi #fi means reverse of if, including condtion end

dnf install maven -y
VALIDATE $? "INSTALLING MAVEN"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping application" 

cd /app &>> $LOGFILE
VALIDATE $? "entering app directory"


unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping application"  

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependences" 

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "renaming packages"

cp /home/centos/roboshop/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping services"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon-reload shipping services"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabeling shipping services"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting  shipping services"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Insatlling shipping"

mysql -h mysql.aleef.fun -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "LOADING INTO ROOT USER"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"


