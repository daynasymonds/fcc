#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -X --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # check if first argument is atomic number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # query by atomic number
    ELEMENT_INFO=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements inner join properties using(atomic_number) inner join types using(type_id) where atomic_number=$1;")
  else
    # query by name/symbol
    ELEMENT_INFO=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements inner join properties using(atomic_number) inner join types using(type_id) where name='$1';") 
    if [[ -z $ELEMENT_INFO ]]
    then
      ELEMENT_INFO=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements inner join properties using(atomic_number) inner join types using(type_id) where symbol='$1';")
    fi
  fi

  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    echo $ELEMENT_INFO | sed 's/ | /|/g' | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi
