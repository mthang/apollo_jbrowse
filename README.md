# Setup Organism and User account in Jbrowse

## Dependencies
```
- python-apollo
- jq
```

## Installation
Install python-apollo client (see [more info](https://github.com/galaxy-genome-annotation/python-apollo)) . Note: Log out and log into VM again after installation.
```
pip install apollo
```
Install jq on Ubuntu (see [more info](https://jqlang.github.io/jq/download/))
```
sudo apt-get install jq
```
## Apollo API Library and usage
Arrow command is used to create organism and user account in Jbrowse (see [Apollo API library](https://python-apollo.readthedocs.io/en/latest/commands.html))

## Setup the connection to Apollo Instance
Use arrow init to set up a connection to the Apollo Instance.
```
arrow int
Please entry your Apollo's URL: https://example.domain/apollo
Please entry your Apollo Username: 
Please entry your Apollo Password:

if connection established successfully:
Testing connection...
Ok! Everything looks good.
Ready to go! Type `arrow` to get a list of commands you can execute.
```

## Step to set up the user account
Before executing the bash script below, prepare a tab delimiter file containing four columns (first name, last name, email and password)
```
Step 1 ) a file containing a list of attendees with 3 columns (first name, last name and email)
Step 2 ) use any password generator for bulk password generation and save it as a single column file (i.e passwords.txt)
Step 3 ) paste -d'\t' file_containing_attendees.txt  passwords.txt > attendees.list  (merge two files side by side)
Step 4 ) bash setup_account.sh 
Note: check if 2bit and organism data folder exists in sourcedata
```

## Troubleshoot
Remove the organism folder named "a_username" and rerun the setup_account.sh again if error message occurs.
```
creating user account for a_username
{
    "error": "Failed to add the user Hibernate operation: could not execute statement; SQL [n/a]; ERROR: duplicate key value violates unique constraint \"grails_user_pkey\"\n  Detail: Key (id)=(34) already exists.; nested exception is org.postgresql.util.PSQLException: ERROR: duplicate key value violates unique constraint \"grails_user_pkey\"\n  Detail: Key (id)=(34) already exists."
}

```
