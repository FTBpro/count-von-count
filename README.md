Setting up a server (Ubuntu 13)
---------------------------------
- install redis-server using apt-get install redis-server
- follow download and install direction on http://openresty.org/#Installation
- add "include /usr/local/openresty/nginx/conf/include/*;" to openresty's nginx.conf, under the 'http' section (by default its in /usr/local/openresty/nginx/conf) 
*** add symlink from /usr/local/openresty/nginx/conf/include/actioncounter.conf (you might need to create the directory first) to the actioncounter.nginx.conf file provided in this project. (sudo ln -sf /usr/local/openresty/nginx/action-counter/config/actioncounter.nginx.conf /usr/local/openresty/nginx/conf/include/actioncounter.conf)
