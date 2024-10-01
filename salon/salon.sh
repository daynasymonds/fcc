#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  AVAILABLE_SERVICES=$($PSQL "select * from services;")
  echo "$AVAILABLE_SERVICES" | while read ID BAR NAME
  do
    echo -e "$ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # get service
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    if [[ $SERVICE_NAME ]]
    then
      SERVICE_SCHEDULER $SERVICE_ID_SELECTED $SERVICE_NAME
    else
      MAIN_MENU "I could not find that service. What would you like today?" 
    fi
  else
    MAIN_MENU "I could not find that service. What would you like today?" 
  fi
}

SERVICE_SCHEDULER() {
  SERVICE_ID=$1
  SERVICE_NAME=$2
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # get customer
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    # get customer name
    read CUSTOMER_NAME
    # insert customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  # get time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU "Welcome to my salon. How can I help you?"