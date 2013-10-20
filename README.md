Setting up a server (Ubuntu 13)
---------------------------------
1) install redis-server using apt-get install redis-server
2) follow download and install direction on http://openresty.org/#Installation
3) install git (sudo apt-get install git)
4) add "include /usr/local/openresty/nginx/conf/include/*;" to openresty's nginx.conf, under the 'http' section (by default its in /usr/local/openresty/nginx/conf)
5) add set worker_rlimit_nofile 30000 in nginx.conf
6) update init.lua with the location of the GeoIP.dat
*** notice - use the provided Capistrano deployment, and you can skip the following steps!
6) add symlink from /usr/local/openresty/nginx/actioncounter to the directory of the project (e.g. /home/deploy/action-counter/current) (sudo ln -sf /home/deploy/action-counter/current/ /usr/local/openresty/nginx/action-counter
7) mkdir /usr/local/openresty/nginx/conf/include
8) add symlink from /usr/local/openresty/nginx/conf/include/actioncounter.conf to the actioncounter.nginx.conf file provided in this project. (sudo ln -sf /usr/local/openresty/nginx/action-counter/config/actioncounter.nginx.conf /usr/local/openresty/nginx/conf/include/actioncounter.conf)
9) start redis-server (sudo service redis-server start) if its not already running
10) start nginx (sudo nginx) if its not already running



Deployment
-----------------
You can use the provided Capistrano deployment (assuming you have Ruby installed).
Edit deploy.rb file and set the correct deploy user and your server,
then run "cap deploy:setup" for the first time, to bootstrap the server (instead of manually doing steps 4-8 above).
use "cap deploy" for deployment :-)


