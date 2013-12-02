Count Von Count
=================
![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

**__NOTICE - if you don't use the default folders as in the instructions, you'll need to edit and change `deploy.rb`, `setup.sh` and  `reload.sh`__**

Setting up a server (Ubuntu 13)
---------------------------------
1. install redis-server using apt-get install redis-server
2. follow download and install direction on http://openresty.org/#Installation. recommended to use default settings and directory structure!
3. install git (sudo apt-get install git)
4. add "include /usr/local/openresty/nginx/conf/include/*;" to openresty's nginx.conf, under the 'http' section (by default its in /usr/local/openresty/nginx/conf)
5. add set worker_rlimit_nofile 30000 in nginx.conf


Deployment
-----------------
### Using Ruby
You can use the provided Capistrano deployment.
Edit deploy.rb file and set the correct deploy user and your servers ips in the `deploy` and `env_servers` variables.
**for the first time** run `cap deploy:setup` to bootstrap the server.
use `cap deploy` to deploy master branch to production.
use `cap deploy -S env=qa -S branch=bigbird` if you want to deploy to a different environment and/or a different branch.

### Using shell scripts 
SSH into your count-von-count server.
**for the first time**
  * clone the git repository into your folder of choice (recommended to use our default - /home/deploy/count-von-count/current)
  * 


GeoIP Plugin
-------------
6) update init.lua with the location of the GeoIP.dat
