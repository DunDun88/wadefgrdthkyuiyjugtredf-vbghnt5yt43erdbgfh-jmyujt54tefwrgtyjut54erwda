#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
teams=()

# Teams is empty outside of while loop due to input method using a subshell.
tail games.csv -n +2 | while IFS= read -a lines 
do 
  IFS="," read -a columns <<< "$lines"
  
  if [[ ! "${teams[*]}" =~ "${columns[2]}" ]] 
  then
    teams+="${columns[2]}"
    $PSQL "INSERT INTO teams(name) VALUES('${columns[2]}')"
  fi

  if [[ ! "${teams[*]}" =~ "${columns[3]}" ]]
  then 
    teams+="${columns[3]}"
    $PSQL "INSERT INTO teams(name) VALUES('${columns[3]}')"
  fi
  
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='${columns[2]}'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='${columns[3]}'")
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('${columns[0]}', '${columns[1]}', '${winner_id}', '${opponent_id}', '${columns[4]}', '${columns[5]}')"
done
