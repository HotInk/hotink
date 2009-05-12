set :application, "hotink"
set :branch, "master"
set :repository,  "git@github.com:HotInk/hotink.git"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/Users/webapp/Sites/hotink-demo"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :git_enable_submodules, 1

set :user, "webapp"
set :use_sudo, false

server "hotink.net", :app, :web, :db, :primary => true

# Recipes below

#############################
# database.yml build recipe

before "deploy:setup", "db:configure"
after "deploy:update_code", "db:symlink"
 
set(:database_username, "hotink-sandbox")
# set(:database_password, "root")
set(:development_database) { application + "_development" }
set(:test_database) { application + "_test" }
set(:production_database) { application + "_production" }
 
namespace :db do
  desc "Create database yaml in shared path"
  task :configure do
    set :database_password do
      Capistrano::CLI.password_prompt "Database Password: "
    end
    
    db_config = <<-EOF
base: &base
  adapter: mysql
  encoding: utf8
  username: #{database_username}
  password: #{database_password}
 
development:
  database: #{development_database}
  <<: *base
 
test:
  database: #{test_database}
  <<: *base
 
production:
  database: #{production_database}
  <<: *base
    EOF
 
    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end
 
  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
end

#############################
# passenger restart recipes

namespace :deploy do
  desc "Restarting Passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

namespace :passenger do  
   desc "Restart Application"  
   task :restart do  
     run "touch #{current_path}/tmp/restart.txt"
   end  
end  
   
after :deploy, "passenger:restart"

#############################
# Thinking Sphinx recipes

desc "Re-establish symlinks"
task :after_symlink do
  run <<-CMD
    rm -fr #{release_path}/db/sphinx &&
    ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
  CMD
end

desc "Stop the sphinx server"
task :stop_sphinx , :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
end


desc "Start the sphinx server"
task :start_sphinx, :roles => :app do
  run "cd #{current_path} && rake thinking_sphinx:configure RAILS_ENV=production && rake thinking_sphinx:start RAILS_ENV=production"
end

desc "Restart the sphinx server"
task :restart_sphinx, :roles => :app do
  stop_sphinx
  start_sphinx
end

