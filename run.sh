#!/bin/bash

MYSQL_USER="root"
MYSQL_PASS=""
MAIL="ferr.tutorialu@gmail.com"
REMOTE_REPOSITORY=https://github.com/EduardoFerr/DumpBase.git

DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIRECTORY"
COMMIT_COUNT=`git rev-list HEAD --count`
COMMIT_COUNT=$(($COMMIT_COUNT+1))

echo 'INICIANDO BACKUP'

echo 'Baixando bancos de dados'
for I in $(mysql -u$MYSQL_USER -p$MYSQL_PASS -e 'show databases where `Database` not in("information_schema")');
do
	if [ "$I" != 'Database' ]
	then
		echo "- $I"
		mysqldump -u$MYSQL_USER -p$MYSQL_PASS --complete-insert "$I" > "$I".sql;
		gzip "$I".sql -f
	fi
done

echo 'Empacotando alterações'
git add .
git commit -m "Backup $COMMIT_COUNT"

echo "Enviando para o repositório remoto" 
git push -u origin master

echo "Avisando administrador"

mail -s "Backup do banco completo" $MAIL <<< "Para acessar o arquivo remoto vá até $REMOTE_REPOSITORY"
echo "BACKUP FINALIZADO"
