# Error handling gem initialized
# All of this code is taken from Gaffe github
Gaffe.configure do |config|
  # This would be for having an API error controller also
  #config.errors_controller = {
    #%r[^/api/] => 'Api::ErrorsController',
    #%r[^/] => 'ErrorsController'
  #}
  config.errors_controller = 'ErrorsController'
end

Gaffe.enable!