#!/bin/bash
while true; do
    echo
    read -p "Enter the desired repository name to create:  "  REPO_NAME
    echo
    read -p "Confirm creation by re-entering the desired repository name again:  "  REPO_NAME_CONFIRMATION
    echo
    [ "$REPO_NAME" = "$REPO_NAME_CONFIRMATION" ] && break || echo "   ----- The two entered repo names don't match; please try again! -----"
done

if [ -z "$REPO_NAME" ]; then
    echo
    echo "ERROR: Repository name can't (and shouldn't...) be empty! Please provide a valid value!"
    exit 1
fi

sudo docker exec -it svn-server svnadmin create $REPO_NAME
sudo docker exec -it svn-server chown -R www-data:subversion /home/svn/$REPO_NAME
sudo docker exec -it svn-server chmod -R g+rws /home/svn/$REPO_NAME
