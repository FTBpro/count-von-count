#!/bin/bash
DEPLOY_TO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."
NGINX_DIR="/usr/local/openresty/nginx"
USER=$(whoami)

chown -R $USER:$USER $NGINX_DIR
ln -sf $DEPLOY_TO/ $NGINX_DIR/count-von-count
mkdir -p $NGINX_DIR/conf/include
ln -sf $DEPLOY_TO/config/voncount.nginx.conf $NGINX_DIR/conf/include/voncount.conf
service redis-server start
$DEPLOY_TO/lib/scripts/reload.sh
$NGINX_DIR/sbin/nginx

if ps aux | grep nginx | grep master > /dev/null ; then
	echo ">>> nginx is running"
else
	echo "ERROR: nginx is not running"
fi

if ps aux | grep redis-server | grep -v 'grep' > /dev/null ; then
	echo ">>> redis-server is running"
else
	echo "ERROR: redis-server is not running"
fi
