server 'stugov.andrew.cmu.edu', user: 'mvella', roles: %w{web app}
set :deploy_to, "/var/www/webapps/#{fetch(:application)}"
set :stage, :production
set :rails_env, :production
