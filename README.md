# SVN Server
## With [Docker](https://www.docker.com/), [docker-compose](https://docs.docker.com/compose/), shell scripts and (optionally) [nginx](https://www.nginx.com/).

This repository holds all the files necessary for creating a minimal, 
simple and painless dockerized SVN Server with easy setup process via docker-compose and shell scripts.

> Tested and production-proven on [Ubuntu 18.04 (x64)](https://ubuntu.com/download/desktop/thank-you?version=18.04.3&architecture=amd64).

## Pre-requisites

* A Linux server (preferably Ubuntu or some variant thereof)
* Full shell access to that
* [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) + [docker-compose](https://docs.docker.com/compose/install/)
* [OPTIONAL] [nginx](https://www.nginx.com)

## Setup

* Clone this repo into some directory on your server (e.g. `~/svn-docker/`)
* `cd` into the freshly cloned repo folder.
* * In here you can find various shell scripts that you will need later to manage your users and back up your instance.
* Open the terminal and `sudo docker-compose up -d`

Great! Your SVN Server should already be running by now. It listens to your `localhost:7878` and `localhost:3690` ports (but you can change that inside the [docker-compose.yml](https://github.com/GlitchedPolygons/svn-server-docker/blob/master/docker-compose.yml) file if needed).

For public inbound internet traffic you'd let some reverse proxy route your requests to those ports (`7878` for HTTP, `3690` for the `svn://` protocol).

By default, all access to the entire instance + repositories is disabled for security reasons.

To grant access to some resources, you need to create a user first. 
This can be done easily using the [`create-user.sh`](https://github.com/GlitchedPolygons/svn-server-docker/blob/master/create-user.sh) script.
Execute `sudo bash create-user.sh` and follow the instructions for setting up your first SVN user.

Now, you are ready to create repositories! 
Run `sudo bash create-repo.sh` and follow the CLI instructions in order to create a new repository. Do not attempt to create a repository that already exists!

## Repository access

Your users still can't access repositories created on your SVN Server though. 
To manage your user permissions, create the file `/mnt/dev/svn/authz` (which, by Docker, is then mapped to the container's `/home/svn/authz` path).

An example of [how such an authz file should look](http://svnbook.red-bean.com/en/1.8/svn.serverconfig.pathbasedauthz.html) could be:

```
[repository_name:/]
* = 
user1 = r
user2 = rw
```
("" empty string means no access at all, "r" means read-only and "rw" means read & write permission).

### Important note about folder paths

By default, this setup uses `/mnt/dev/svn` as the folder path to the docker mounted volume 
(because theoretically, it'd make sense to mount some persistent storage device to this path).

Unless explicitly needed, do not change this (it is possible, yes, but you'd need to replace it in every single shell script file and docker config files).

**Absolutely make sure** that this volume path exists on your server host's machine (and that it has enough space to host your repositories, of course)!
> **HINT:** use `mkdir -p /mnt/dev/svn` before starting your setup process to be on the safe side.

Backups are exported by default into `./backups/`.

## Backups

To back up your entire SVN Server instance, run `sudo bash backup.sh`. The docker container is stopped, its mounted volume `/mnt/dev/svn:/home/svn` is then gzipped into `./backups` and the container is rebooted.

Your backups are safely deposited into the `./backups/` folder, but if you want you can encrypt those files using a strong algorithm and upload them to some cloud storage provider for maximum safety (if there ever is such a thing...).

> **HINT:** You can [crontab](https://crontab.guru/) the execution of this [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) script and schedule automated backups like this.

## Nginx
#### Example nginx config

If you use nginx as your reverse-proxy, take a look at the following example server block. 
It demonstrates how you could set up a domain that is pointed to your server's IP address (in this example, `svn.example.com` is used).

```nginx
server {
   server_name svn.example.com;
   location / {
      set $fixed_destination $http_destination;
      if ( $http_destination ~* ^https(.*)$ ) {
         set $fixed_destination http$1;
      }
      proxy_set_header   Destination $fixed_destination;
      proxy_set_header   Upgrade $http_upgrade;
      proxy_set_header   Connection keep-alive;
      proxy_set_header   Host $host;
      proxy_pass         http://localhost:7878;
   }
   client_max_body_size 0;

   listen 443 ssl; # managed by Certbot
   ssl_certificate /etc/letsencrypt/live/svn.example.com/fullchain.pem; # managed by Certbot
   ssl_certificate_key /etc/letsencrypt/live/svn.example.com/privkey.pem; # managed by Certbot
   include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
   ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
   if ($host = svn.example.com) {
      return 301 https://$host$request_uri;
   } # managed by Certbot

   server_name svn.example.com;
   listen 80;
   return 404; # managed by Certbot
}
```

* As you can see, the `svn://` protocol is ignored completely and HTTP requests to the server are force-redirected to HTTPS.
* SSL requests are terminated already here on the host's machine to avoid having to set up a complex web server from within the container.
* * Because of this, the `Destination` header [needs to be rewritten to plain HTTP](https://stackoverflow.com/a/27358621) as seen above.
* Thanks to Let's Encrypt + Certbot, [HTTPS setup has never been easier before](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04).
* * `sudo certbot --nginx -d svn.example.com`

---
