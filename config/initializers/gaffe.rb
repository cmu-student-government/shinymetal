# Error handling gem initialized
# All of this code is taken from Gaffe github
Gaffe.configure do |config|
  config.errors_controller = 'ErrorsController'
end

Gaffe.enable!