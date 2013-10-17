# set :application, "set your application name here"
# set :repository,  "set your repository location here"

# # set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

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
# set(:rails_env) { stage }

server "54.212.253.88", :app, :web, :db

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
    run "sudo echo 'set \$redis_reads_hash '$(redis-cli SCRIPT LOAD \"$(cat '#{deploy_to}/current/lib/actioncounter.lua')\")';' > #{nginx_dir}/conf/vars.conf"
    run "sudo echo 'set \$redis_mobile_hash '$(redis-cli SCRIPT LOAD \"$(cat '#{deploy_to}/current/lib/redis_mobile.lua')\")';' >> #{nginx_dir}/conf/vars.conf"
  end

  task :restart do
    nginx.reload
  end
end
