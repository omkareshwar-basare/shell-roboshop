#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"

SCRIPT_DIR=$PWD

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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling NodeJS Default Version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop already exits.....SKIPPING"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing Existing Code"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip catalogue code"

npm install
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "created systemctl service"

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
VALIDATE $? "Starting and enabling Catalogue"









