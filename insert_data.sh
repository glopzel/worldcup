#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# clean tables !!!
echo $($PSQL "TRUNCATE games, teams")

# add name to teams
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  # add teams
  if [[ $WINNER != "winner" ]]  
  then
    # check if the team is on the table, if there is no team_id, add it to the table
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    if [[ -z $TEAM_ID ]] 
    then
      ADD_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      
      if [[ $ADD_TEAM_RESULT == "INSERT 0 1" ]] 
      then
        echo added team $WINNER
      fi
      # get team id
      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    else
      W_TEAM_ID=$TEAM_ID
    fi 
  fi

  if [[ $OPPONENT != "opponent" ]]
  then
    # check if there is a team id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
    if [[ -z $TEAM_ID ]]
    then
      ADD_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ -z $TEAM_ID ]] 
      then
        echo added team $OPPONENT
      fi
      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    else
      O_TEAM_ID=$TEAM_ID
    fi    
  fi

  if [[ $YEAR != 'year' ]]
  then
    INSERT_EVERYTHING=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$W_TEAM_ID,$O_TEAM_ID,$WGOALS,$OGOALS)")
    if [[ $INSERT_EVERYTHING == "INSERT 0 1" ]]
    then
      echo you added everything, crazy times
    fi
  fi
done

