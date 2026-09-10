#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


CHECK_USER() {
  echo Enter your username:
  read USERNAME
  STORED_USER=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  if [[ -z $STORED_USER ]]
  then
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    INSERT_GAME_DATA=$($PSQL "INSERT INTO user_games(user_id, games_played, best_game) VALUES($USER_ID, 0, 100000);")
    echo Welcome, $USERNAME! It looks like this is your first time here.
  else
    PLAYER_STATS=$($PSQL "SELECT games_played, best_game FROM user_games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    echo "$PLAYER_STATS" | while IFS="|" read GAMES_PLAYED BEST_GAME
    do
      echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
    done
  fi
}

PLAY_GAME() {
  CHECK_USER
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM user_games WHERE user_id=$USER_ID")
  NUMBER_TO_GUESS=$(( (RANDOM % 1000) + 1 ))
  NUMBER_OF_TRIES=0
  WRONG_GUESS=True
  echo Guess the secret number between 1 and 1000:
  while true
  do
    read USER_GUESS
    if [[ $USER_GUESS =~ ^[0-9]+$ ]]
    then
      (( NUMBER_OF_TRIES+=1 ))
      if [[ $USER_GUESS -eq $NUMBER_TO_GUESS ]]
      then
        (( GAMES_PLAYED+=1 ))

        if [[ $NUMBER_OF_TRIES -lt $BEST_GAME ]]
        then
          RECORD_GAME=$($PSQL "UPDATE user_games SET games_played=$GAMES_PLAYED, best_game=$NUMBER_OF_TRIES WHERE user_id=$USER_ID")
        else
          RECORD_GAME=$($PSQL "UPDATE user_games SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
        fi
        echo You guessed it in $NUMBER_OF_TRIES tries. The secret number was $NUMBER_TO_GUESS. Nice job!
        break
      elif [[ $USER_GUESS -gt $NUMBER_TO_GUESS ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $USER_GUESS -lt $NUMBER_TO_GUESS ]]
      then
        echo "It's higher than that, guess again:"
      fi
    else
      echo That is not an integer, guess again:
    fi
  done
}

PLAY_GAME