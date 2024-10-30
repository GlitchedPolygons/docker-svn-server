FROM ubuntu:24.04

ARG SVN_HOME=/home/svn
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y subversion apache2 libapache2-mod-svn libsvn-dev && \
    a2enmod dav && \
    a2enmod dav_svn && \
    mkdir -p ${SVN_HOME} && \
    groupadd subversion && \
    usermod -a -G subversion www-data && \
    usermod -a -G subversion root && \
    chown -R www-data:subversion ${SVN_HOME} && \
    chmod -R g+rws ${SVN_HOME}
    
COPY dav_svn.conf /etc/apache2/mods-enabled/
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
