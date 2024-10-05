#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# lookup user
USER=$($PSQL "select username from games where username='$USERNAME' order by game_id desc limit 1;")

# if user has not played before
if [[ -z $USER ]]
then 
  # print welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here."  
else
  # get total games played
  TOTAL_GAMES_PLAYED=$($PSQL "select count(*) from games where username='$USERNAME';")
  # get best game with least number of guesses
  BEST_GAME_GUESSES_COUNT=$($PSQL "select min(guess_count) from games where username='$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $TOTAL_GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES_COUNT guesses."
fi

# create game for user
NEW_GAME_RESULT=$($PSQL "insert into games (username) values ('$USERNAME');")
# get game id
GAME_ID=$($PSQL "select game_id from games where username='$USERNAME' order by game_id desc limit 1;")

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
GUESS_COUNT=0

# start the game
echo "Guess the secret number between 1 and 1000:"

# initialise guess to start loop
GUESS=$(( $SECRET_NUMBER - 1 ))
while [ $GUESS != $SECRET_NUMBER ]
do 
  read GUESS
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
  if [[ $GUESS =~ ^[1-9][0-9]*$ ]]
  then
    if [[ $GUESS != $SECRET_NUMBER ]]
    then
      if [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

NUMBER_OF_GUESSES=$GUESS_COUNT

GAME_RESULT=$($PSQL "update games set guess_count=$NUMBER_OF_GUESSES where game_id=$GAME_ID;")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"