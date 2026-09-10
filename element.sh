#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
DATA=$($PSQL "SELECT * FROM elements")

if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    CHOSEN_ELEMENT_MAIN_INFO=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1")
  else
  CHOSEN_ELEMENT_MAIN_INFO=$($PSQL "SELECT * FROM elements WHERE name='$1' OR symbol='$1'")
  fi
  if [[ -z $CHOSEN_ELEMENT_MAIN_INFO ]]
  then
    echo -e "I could not find that element in the database."
  else
    echo "$CHOSEN_ELEMENT_MAIN_INFO" | while IFS="|" read ID SYMBOL NAME
    do
      GET_ELEMENT_INFO=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING(type_id) WHERE $ID=atomic_number")
      echo "$GET_ELEMENT_INFO" | while IFS="|" read TYPE MASS MELT_POINT BOIL_POINT
      do
        echo -e "The element with atomic number $ID is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
      done
    done
  fi
else
  echo Please provide an element as an argument.
fi
