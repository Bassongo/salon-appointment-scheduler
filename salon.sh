#! /bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
AVAILABLE_SERVICES=$(psql  -U postgres  -d salon -t -A -F '|' -c "SELECT service_id, name FROM services;")
echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID NAME
do
  echo "$SERVICE_ID) $NAME"
done

PSQL="psql -U postgres -d salon -t -A -F '|'"

show_services() {
  echo "Available services:"
  $PSQL -c  "SELECT service_id, name FROM services " | while IFS='|' read SERVICE_ID NAME
  do
    CLEAN_NAME=$(echo "$NAME" | sed "s/^['\"]//;s/['\"]$//")
    CLEAN_ID=$(echo "$SERVICE_ID" | sed "s/^['\"]//;s/['\"]$//")
    echo "$CLEAN_ID) $CLEAN_NAME"
  done
}
VALID_SELECTION=false
while [ "$VALID_SELECTION" = false ]; do
  show_services
  echo -e "\nPlease enter the number of the service you want:\n"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | xargs)

  # Vérifie si SELECTED_ID est un des ID valides
  ID_EXISTS=$($PSQL -c "SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED LIMIT 1;")

  if [[ "$ID_EXISTS" == "1" ]]; then
    VALID_SELECTION=true
   break
  else
    echo -e "\nInvalid selection. Please try again.\n"
  fi
done
echo -e "\nPlease enter your phone number:\n"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';" | xargs)

if [[ -z "$CUSTOMER_NAME" ]]; then
  echo "You are not in our system. What's your name?"
  read CUSTOMER_NAME
  INSERT_RESULT=$($PSQL -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
fi
echo -e "\nAt what time would you like your appointment? \n"
read SERVICE_TIME
CUSTOMER_ID=$($PSQL -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
INSERT_APPOINTMENT_RESULT=$($PSQL -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
