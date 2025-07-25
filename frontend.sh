#!/bin/bash

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(echo $0 | cut -d "."  -f1)
TIMESTAPM=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAPM.log"
mkdir -p $LOGS_FOLDER



USERID=$(id -u)
#echo "user id is: $USERID"
R="\e[31m"
G="\e[32m"
N="\e[0"
Y="\e[33m"
CHECK_ROOT()
{
    if [ $USERID -ne 0 ]
    then 
           echo -e  "$R please run this script with root privilages $N" &>>$LOG_FILE #To store in the log file.
           exit 1
    fi       
}
VALIDATE()
{
  if [ $1 -ne 0 ]
  then 
      echo -e "$2 is $R failed.... $N" | tee -a $LOG_FILE
      exit 1
  else 
      echo -e "$G $2 is  success $N" | tee -a $LOG_FILE
  fi      
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installed Nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabled Nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Started Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend application code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting frontend application code"

systemctl restart nginx