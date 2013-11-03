DEPLOY_TO='/home/deploy/action-counter'
USER="deploy"
NGINX_DIR="/usr/local/openresty/nginx"

chown -R $USER:$USER $NGINX_DIR
ln -sf $DEPLOY_TO/current/ $NGINX_DIR/action-counter
mkdir -p $NGINX_DIR/conf/include
ln -sf $DEPLOY_TO/current/config/actioncounter.nginx.conf $NGINX_DIR/conf/include/actioncounter.conf
service redis-server start
nginx

