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
      echo -e "$2 is $G success $N" | tee -a $LOG_FILE
  fi      
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE
CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "Installing mySQL server"

systemctl enable mysqld
VALIDATE $? "enabled mySQL server"

systemctl start mysqld
VALIDATE $? "start mySQL server"

mysql -h daws81s.daws81.space -u root -pExpenseApp@1 -e 'show databases:' &>>$LOG_FILE
if [ $? -ne 0]
then 
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Settingup root password"
else
    echo -e "MySQL root password already setup.. $Y SKIPPING $N"  | tee -a $LOG_FILE
fi   