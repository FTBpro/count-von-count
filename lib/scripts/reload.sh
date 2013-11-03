DEPLOY_TO='/home/deploy/action-counter'
NGINX_DIR="/usr/local/openresty/nginx"

rm -f $NGINX_DIR/conf/include/vars.conf
echo 'set \$redis_counter_hash '$(redis-cli SCRIPT LOAD \"$(cat '$DEPLOY_TO/current/lib/actioncounter.lua')\")';' > $NGINX_DIR/conf/vars.conf
redis-cli set action_counter_config_live \"$(cat '#{deploy_to}/current/config/actioncounter.config' | tr -d '\n' | tr -d ' ')\"
nginx -s reload
