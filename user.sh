#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.sivadevops.fun

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y  &>>$LOGFILE

VALIDATE $? "Diasbling nodejs current version"

dnf module enable nodejs:18 -y  &>>$LOGFILE

VALIDATE $? "Enabling nodejs:18 version"

dnf install nodejs -y  &>>$LOGFILE

VALIDATE $? "Installing nodejs"

id roboshop

if [ $? -ne 0 ]

then
    
    useradd roboshop

    VALIDATE $? "Creating user roboshop"

else

    echo -e "Roboshop user already exists $Y SKIPPING $N"

fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip   &>> $LOGFILE

VALIDATE $? "Downloading user application"

cd /app 

unzip /tmp/user.zip  &>> $LOGFILE

VALIDATE $? "Downloading user application code"

npm install  &>> $LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell-78s/user.service /etc/systemd/system/user.service  &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell-78s/mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into MongoDB"





















