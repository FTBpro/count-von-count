DEPLOY_TO='/home/deploy/count-von-count/current'
NGINX_DIR="/usr/local/openresty/nginx"
USER=$(whoami)

chown -R $USER:$USER $NGINX_DIR
ln -sf $DEPLOY_TO/ $NGINX_DIR/count-von-count
mkdir -p $NGINX_DIR/conf/include
ln -sf $DEPLOY_TO/config/voncount.nginx.conf $NGINX_DIR/conf/include/voncount.conf
service redis-server start
./reload.sh
$NGINX_DIR/sbin/nginx

