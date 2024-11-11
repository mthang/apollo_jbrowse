#!/bin/bash

# install arrow with pip install apollo and source .bashrc

#Define blat/blast search db
BLAT=/home/data/sourcedata/blat/MG1655/db/genome.2bit

#Define organism name
ORGANISM=MG1655

#Define organism folder in sourcedata
SOURCEDATA=/home/data/sourcedata

#Define destination folder
DESTINATION=/home/data/apollo_data

#setup user on apollo VM
#--role : default user ( admin will be used in this script)

#define genus and species
GENUS=e
SPECIES=coli

ATTENDEE=example.txt

########################
#
# before running this script
# make sure to run - arrow init to create a connection to your apollo instance 
#
#########################

while read -r LINE
do
 
  FIRSTNAME=`echo $LINE | awk '{print $1}'`
  LASTNAME=`echo $LINE | awk '{print $2}'`
  EMAIL=`echo $LINE | awk '{print $3}'`
  PASSWORD=`echo $LINE | awk '{print $4}'`
  echo -e "$FIRSTNAME $LASTNAME $EMAIL $PASSWORD"
  # check if the organism folder exists
  if [ ! -d "$DESTINATION/$LASTNAME" ];then
     echo "$DESTINATION/$LASTNAME does not exist and creating folder $LASTNAME"
     # copy organism folder from sourcedata folder to apollo_data folder
     cp -r $SOURCEDATA/$ORGANISM $DESTINATION/$LASTNAME
     # check if the organism exists in Jbrowse
         ORGANISM_DIR=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName | contains($folderName)) | any'`
     # add the organism to the jbrowse if it does not exist yet
     if [ "$ORGANISM_DIR" != true ];then
	echo -e "$ORGANISM_DIR exists and adding this organism to JBrowse"
	arrow organisms add_organism --blatdb $BLAT --genus $GENUS --species $SPECIES $LASTNAME $DESTINATION/$LASTNAME
	# obtain organism id associated with the username last name
	   ORGANISM_ID=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName==$folderName) | .id'`
	# check if the user exists using username last name
	   GET_USER=`arrow users get_users | jq --arg LASTNAME $LASTNAME '.[] | select(.lastName | contains($LASTNAME)) | any'`
	# if the user does not exist , create a user account as an admin and grant the user with full permissions
	if [ "$GET_USER" != true ];then
	   echo -e "creating user account for $LASTNAME"
	   arrow users create_user --role admin $EMAIL $FIRSTNAME $LASTNAME $PASSWORD
	   arrow users update_organism_permissions --administrate --write --export --read $EMAIL $ORGANISM_ID
        else
 	   echo "Grant organism permission (if exists) to the user"
	   ORGANISM_ID=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName==$folderName) | .id'`
	   arrow users update_organism_permissions --administrate --write --export --read $EMAIL $ORGANISM_ID
	fi
     fi
  else
     # if the organism exists (check if it's in Jbrowse), then check if the user exist and grant permission to the user
     GET_USER=`arrow users get_users | jq --arg LASTNAME $LASTNAME '.[] | select(.lastName | contains($LASTNAME)) | any'`
     if [ "$GET_USER" != true ];then
     	echo -e "creating user account for $LASTNAME"
     	arrow users create_user --role admin $EMAIL $FIRSTNAME $LASTNAME $PASSWORD
	ORGANISM_DIR=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName | contains($folderName)) | any'`
	if [ "$ORGANISM_DIR" == true ];then
	   echo -e "$ORGANISM_DIR exists and Grant organism permission for the user"
	   ORGANISM_ID=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName==$folderName) | .id'`
	   arrow users update_organism_permissions --administrate --write --export --read $EMAIL $ORGANISM_ID
	fi
     else
	echo "Organism and User account already created, but not the permission"
	ORGANISM_ID=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName==$folderName) | .id'`
	ORGANISM_DIR=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName | contains($folderName)) | any'`
	PERMISSION=`arrow users get_organism_permissions $EMAIL | jq '.[].permissions'`
	if [ "$ORGANISM_DIR" == true ] && [ "$GET_USER" == true ] && [ "$PERMISSION" == "" ];then
	   echo -e "Grant organism permission for the user"
	   ORGANISM_ID=`arrow organisms get_organisms | jq --arg folderName $LASTNAME '.[] | select(.commonName==$folderName) | .id'`
	   arrow users update_organism_permissions --administrate --write --export --read $EMAIL $ORGANISM_ID
	else
	   echo -e "Permission already granted for $LASTNAME user"
	fi
     fi
   fi
done < "$ATTENDEE"
