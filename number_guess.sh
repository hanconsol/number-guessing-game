#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# generate random number
SECRET_NUMBER=$(( RANDOM % 1000 ))
# get username
GET_USERNAME() {
echo Enter your username: 
read USERNAME
# get user id
USER_ID=$($PSQL "SELECT user_id FROM user_info WHERE username = '$USERNAME'")
# if username doesn't exist
if [[ -z $USER_ID ]]
# add new user 
then
  ADD_USER_RESULT=$($PSQL "INSERT INTO user_info(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM user_info WHERE username = '$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=1000
# new user message
echo -e "Welcome, $USERNAME! It looks like this is your first time here."
# else get user data 
else 

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT  best_game FROM user_info WHERE user_id = $USER_ID")

  
  # welcome back message
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
# set reset guess count
fi
NUMBER_OF_GUESSES=0
echo Guess the secret number between 1 and 1000:
echo $SECRET_NUMBER
GET_GUESS 
}
# get guess
GET_GUESS() {
  read GUESS
# if not integer 
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
# guess again message
echo That is not an integer, guess again:
read GUESS
done
HANDLE_GUESS
}
HANDLE_GUESS() { 
# increment guess count
NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
# check guess
# if guess equals
if [[ $GUESS = $SECRET_NUMBER ]]
then
SUCCESS
else 
# if guess greater than.
if [[ $GUESS -gt $SECRET_NUMBER ]]
then
# message & get guess
echo -e "It's lower than that, guess again:"
GET_GUESS

else
# if guess less than
if [[ $GUESS -lt $SECRET_NUMBER ]]
then
# message & get guess
echo -e "It's higher than that, guess again:"
GET_GUESS
fi
fi
fi
}
SUCCESS() {
# compare guess count to best game
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
BEST_GAME_RESULT=$($PSQL "UPDATE user_info SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")
BEST_GAME=$NUMBER_OF_GUESSES
fi
# increment games played
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
#  update user info
GAMES_PLAYED_RESULT=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
# print success message
echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

GET_USERNAME