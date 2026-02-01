#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"

if [ $USERID -ne 0 ]; then
   echo "Please run the script with root user access" | tee -a $LOGS_FILE
   exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE(){
if [ $1 -ne 0 ]; then
   echo "$2...FAILURE" | tee -a $LOGS_FILE
   exit 1
else
    echo "$2...SUCCESS" | tee -a $LOGS_FILE
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod
VALIDATE $? "Enable Mongodb"

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.config
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted Mongod"

