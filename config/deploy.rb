# -------------------------------------------
# Git and deploytment details
# -------------------------------------------
set :application, "action-counter"
set :repository,  "git://github.com/FTBpro/action-counter.git"
set :scm, :git
set :deploy_to, '/home/deploy/action-counter'
set :user, "deploy"
set :use_sudo, false
set :nginx_dir, "/usr/local/openresty/nginx"

env_servers = { production: "***.***.***.***", qa: "***.***.***.***" }
server env_servers[env.to_sym], :app, :web, :db

after 'deploy:setup', 'nginx:folder_permissions', 'symlink:app', 'symlink:conf', 'redis:start', 'nginx:start'
before 'deploy:restart', 'deploy:load_redis_lua'

namespace :symlink do
  desc "Symlink nginx to application folder"
  task :app do
    run "sudo ln -sf #{deploy_to}/current/ #{nginx_dir}/action-counter"
  end

  desc "Symlink to actioncounter.nginx.conf"
  task :conf do
    run "sudo mkdir -p #{nginx_dir}/conf/include"
    run "sudo ln -sf #{deploy_to}/current/config/actioncounter.nginx.conf #{nginx_dir}/conf/include/actioncounter.conf"
  end
end


namespace :nginx do
  task :start do
    run "sudo nginx"
  end

  task :stop do
    run "sudo nginx -s stop"
  end

  desc "Reload nginx with current configuration"
  task :reload do
    run "sudo nginx -s reload"
  end

  task :folder_permissions do
    run "sudo chown -R #{user}:#{user} #{nginx_dir}"
  end
end

namespace :redis do
  task :start, roles: :db do
    run "sudo service redis-server start"
  end

  task :stop, roles: :db do
    run "sudo service redis-server start"
  end

  task :restart, roles: :db do
    run "sudo service redis-server restart"
  end
end

namespace :deploy do
  desc "Load the lua script to redis and saving the SHA in a file for nginx to use"
  task :load_redis_lua do
    run "sudo rm -f #{nginx_dir}/conf/include/vars.conf"
    run "sudo echo 'set \$redis_counter_hash '$(redis-cli SCRIPT LOAD \"$(cat '#{deploy_to}/current/lib/actioncounter.lua')\")';' > #{nginx_dir}/conf/vars.conf"
    run "sudo echo 'set \$redis_mobile_hash '$(redis-cli SCRIPT LOAD \"$(cat '#{deploy_to}/current/lib/redis_mobile.lua')\")';' >> #{nginx_dir}/conf/vars.conf"
    run "sudo redis-cli set action_counter_config_live \"$(cat '#{deploy_to}/current/config/actioncounter.config' | tr -d '\n' | tr -d ' ')\""
  end

  task :restart do
    nginx.reload
  end
end
