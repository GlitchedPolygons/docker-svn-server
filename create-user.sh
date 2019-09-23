#!/bin/bash
# RUN THIS SCRIPT DIRECTLY FROM THE HOST MACHINE, NOT FROM WITHIN THE DOCKER CONTAINER!
echo
read -p "Enter new username:  "  USERNAME
if [ -z "$USERNAME" ]; then
	echo
	echo "ERROR: Text value empty - Please provide a valid value!"
    exit 1
fi
sudo docker exec -it svn-server touch /home/svn/passwd
sudo docker exec -it svn-server htpasswd -B /home/svn/passwd $USERNAME 
