#!/bin/bash

################################################################
##
##   MySQL Database Export From one Server To Import To another Server 
##   Written By: Kawal Jain
##   Website: http://kawaljain.com/
################################################################


export PATH=/bin:/usr/bin:/usr/local/bin

TODAY=`date +"%d%b%Y"`

################################################################
################## Constant Values  ########################

DB_BACKUP_PATH='db_backup'


UAT_MYSQL_HOST='localhost'              # Uat Server Host
UAT_MYSQL_PORT='3306'                   # Uat Server PORT
UAT_MYSQL_USER='root'                   # Uat Server Username
UAT_MYSQL_PASSWORD='password'           # Uat Server PASSWORD
UAT_DATABASE_NAME='test_uat'    # Uat Server Database name



PRODUCTION_MYSQL_HOST='localhost'    # PROD Server Host
PRODUCTION_MYSQL_PORT='3306'    # PROD Server Port
PRODUCTION_MYSQL_USER='root'    # PROD Server Username
PRODUCTION_MYSQL_PASSWORD='password'    # PROD Server Password
PRODUCTION_DATABASE_NAME='test_prod'    # PROD Server Database Name


UAT_DB_FILE_NAME="UAT_${UAT_DATABASE_NAME}-${TODAY}";
PROD_DB_FILE_NAME="PROD_${PRODUCTION_DATABASE_NAME}-${TODAY}";


#################################################################

mkdir -p ${DB_BACKUP_PATH}/
echo "Backup started from Uat database - ${UAT_DATABASE_NAME}"

mysqldump -h ${UAT_MYSQL_HOST} \
		  -P ${UAT_MYSQL_PORT} \
		  -u ${UAT_MYSQL_USER} \
		  -p${UAT_MYSQL_PASSWORD} \
		  ${UAT_DATABASE_NAME} > ${DB_BACKUP_PATH}/${UAT_DB_FILE_NAME}.sql

if [ $? -eq 0 ]; then 
    #  $? is the exit status of the last executed command. -eq check its equal to zero or not. 
    #  If respose is zero then, it successfully executed
        echo "UAT Database backup successfully completed"

    ##### Importing db   #####
        echo "Backup of Production Started"

        mysqldump -h ${PRODUCTION_MYSQL_HOST} \
            -P ${PRODUCTION_MYSQL_PORT} \
            -u ${PRODUCTION_MYSQL_USER} \
            -p${PRODUCTION_MYSQL_PASSWORD} \
            ${PRODUCTION_DATABASE_NAME} > ${DB_BACKUP_PATH}/${PROD_DB_FILE_NAME}.sql

        if [ $? -eq 0 ]; then 
            echo "Production Database backup successfully completed"
            echo "Importing UAT database to Production"
                mysql -h ${PRODUCTION_MYSQL_HOST} \
                    -P ${PRODUCTION_MYSQL_PORT} \
                    -u ${PRODUCTION_MYSQL_USER} \
                    -p${PRODUCTION_MYSQL_PASSWORD} \
                    ${PRODUCTION_DATABASE_NAME} < ${DB_BACKUP_PATH}/${UAT_DB_FILE_NAME}k.sql
            if [ $? -eq 0 ]; then 
                echo "Imported Succesfully, Now Removing UAT DB".;
                rm -rf ${DB_BACKUP_PATH}/${UAT_DB_FILE_NAME}.sql;
                echo "Done";

            else
                echo "Error in importing UAT database to Production database. Import Previous production database.";
                mysql -h ${PRODUCTION_MYSQL_HOST} \
                    -P ${PRODUCTION_MYSQL_PORT} \
                    -u ${PRODUCTION_MYSQL_USER} \
                    -p${PRODUCTION_MYSQL_PASSWORD} \
                    ${PRODUCTION_DATABASE_NAME}< ${DB_BACKUP_PATH}/${PROD_DB_FILE_NAME}.sql
            fi

        else
            echo "Error found during backup of Production db"
        fi

else
  echo "Error found during backup"
fi
### End of script ####
