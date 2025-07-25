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

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    echo -e "expense user not exists...$G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi    

mkdir -p /app
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloadig backend application code"

cd /app
rm -rf /app/* #remove the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting backend application code"

npm install &>>$LOG_FILE
cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service

#load the data before starting backend

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL client"

mysql -h daws81s.daws81.space -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enable backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restart backend"
