class ErrorsController < ApplicationController
  # Include the gaffe gem functionality
  include Gaffe::Errors
  
  # Override Gaffe error layout with normal layout
  layout 'application'
  
  # Render the correct template based on the exception ÒstandardÓ code.
  # Eg. For a 404 error, the `errors/not_found` template will be rendered.
  def show
    # Set current_user from session hash if there is one
    current_user
    # @rescue_response is the name of the error for a typical error.
    # Here, an `@exception` variable contains the original raised error
    respond_to do |format|
      format.html { render status: @status_code }
      format.json {
        render json: {error: "Internal server error; please try again later."}, status: 500
        }
    end
  end
end
