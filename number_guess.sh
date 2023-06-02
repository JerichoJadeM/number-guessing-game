#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new player
  INSERT_USERNAME=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE player_id=$PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guess) FROM games WHERE player_id=$PLAYER_ID")
  echo -e "\nWelcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

GUESS_COUNT=0
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

MAKE_GUESS() {
  read PLAYER_GUESS
  while [[ ! $PLAYER_GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read PLAYER_GUESS
  done
  GUESS_COUNT=$(($GUESS_COUNT + 1))
}

MAKE_GUESS

while [[ $PLAYER_GUESS != $SECRET_NUMBER ]]
do
  if [[ $PLAYER_GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  MAKE_GUESS
done

if [[ -z $GAMES_PLAYED ]]
then
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
  #INSERT_GAMES_RESULT=$($PSQL "UPDATE games SET games_played=1, number_of_guess=$GUESS_COUNT WHERE player_id=$PLAYER_ID")
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(player_id, number_of_guess, games_played) VALUES($PLAYER_ID, $GUESS_COUNT, 1)")
else
  INSERT_GAMES_RESULT=$($PSQL "UPDATE games SET games_played=$(($GAMES_PLAYED + 1)), number_of_guess=$(($GUESS_COUNT<$BEST_GAME?$GUESS_COUNT:$BEST_GAME)) WHERE player_id=$PLAYER_ID")
fi

echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
