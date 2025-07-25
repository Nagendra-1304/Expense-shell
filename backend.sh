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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable the default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

useradd expense &>>$LOG_FILE
VALIDATE $? "Creating expense user"