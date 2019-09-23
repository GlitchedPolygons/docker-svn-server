#!/bin/bash
# RUN THIS SCRIPT DIRECTLY FROM THE HOST MACHINE, NOT FROM WITHIN THE DOCKER CONTAINER!
while true; do
    echo
    read -p "Enter the username to delete:  "  USERNAME
    echo
    read -p "Confirm deletion by re-entering the username again:  "  USERNAME_CONFIRMATION
    echo
    [ "$USERNAME" = "$USERNAME_CONFIRMATION" ] && break || echo "   ----- The two entered usernames don't match; please try again! -----"
done

if [ -z "$USERNAME" ]; then
    echo
    echo "ERROR: Username can't (and shouldn't...) be empty! Please provide a valid value!"
    exit 1
fi
sudo docker exec -it svn-server htpasswd -D /home/svn/passwd $USERNAME 
