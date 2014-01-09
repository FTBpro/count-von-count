#!/bin/bash
DEPLOY_TO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."
NGINX_DIR="/usr/local/openresty/nginx"

rm -f $NGINX_DIR/conf/include/vars.conf
echo 'set $redis_counter_hash '$(redis-cli SCRIPT LOAD "$(cat $DEPLOY_TO'/lib/redis/voncount.lua')")';' > $NGINX_DIR/conf/vars.conf
redis-cli set von_count_config_live $(cat $DEPLOY_TO'/config/voncount.config' | tr -d '\n' | tr -d ' ')
$NGINX_DIR/sbin/nginx -s reload
