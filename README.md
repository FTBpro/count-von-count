Count Von Count
=================
![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

Setting up a server (Ubuntu 13)
---------------------------------
1. install redis-server using apt-get install redis-server
2. follow download and install direction on http://openresty.org/#Installation. recommended to use default settings and directory structure!
3. install git (sudo apt-get install git)
4. add "include /usr/local/openresty/nginx/conf/include/*;" to openresty's nginx.conf, under the 'http' section (by default its in /usr/local/openresty/nginx/conf)
5. add set worker_rlimit_nofile 30000 in nginx.conf



Deployment
-----------------
You can use the provided Capistrano deployment (assuming you have Ruby installed).
Edit deploy.rb file and set the correct deploy user and your server,
then run "cap deploy:setup" for the first time, to bootstrap the server (instead of manually doing steps 4-8 above).
use "cap deploy" for deployment :-)



GeoIP Plugin
-------------
6) update init.lua with the location of the GeoIP.dat
