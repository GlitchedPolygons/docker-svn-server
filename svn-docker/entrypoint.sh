#!/bin/bash
# ---------> ONLY RUN THIS SCRIPT FROM WITHIN THE CONTAINER!
service apache2 start
tail -f /var/log/apache2/error.log
