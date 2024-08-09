#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# This will delete everything in the table for clean entry
echo "$($PSQL"TRUNCATE teams, games;")"

# OPEN THE FILE AND READ ITS CONTENT
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

## TEAMS TABLE INSERTION ##############################################################################
  # PREVENT READING THE FIRST ROW WITH NAMINGS
  if [[ $YEAR != "year" ]]
  then
    
    # GET THE ID OF THE TEAMS AND SEE IF IT'S IN THE .DB ALREADY  
    WINNER_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL"SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # IF WE DON'T HAVE BOTH, THEN ADD THEM 
    if [[ -z $WINNER_ID && -z $OPPONENT_ID ]]
    then    
      echo $($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      echo $($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT')") 

      WINNER_ID="$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER'")"
      OPPONENT_ID="$($PSQL"SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    
    # IF ONLY THE WINNER ISN'T, JUST ADD HIM
    elif [[ -z $WINNER_ID ]]
    then
      echo $($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      WINNER_ID="$($PSQL"SELECT team_id FROM teams WHERE name='$WINNER'")"
    
    # ADD THE OPPONENT IF HE IS NOT, BUT THE WINNER IS ALREADY
    elif [[ -z $OPPONENT_ID ]]
    then
        echo $($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT')")
        OPPONENT_ID="$($PSQL"SELECT team_id FROM teams WHERE name='$OPPONENT'")"

    # IF EVERYONE IS, JUST CONTINUE WITH THE NEXT DATA
    else
      echo "Nothing now..."
    fi

## GAMES TABLE INSERTION ##############################################################################
      echo "$($PSQL"INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
      echo $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS

  fi

done