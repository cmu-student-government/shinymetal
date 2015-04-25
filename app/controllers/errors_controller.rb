# Manages all html error pages.
class ErrorsController < ApplicationController
  # Include the gaffe gem functionality for error handling.
  # This particular gem raises UTF warnings when using YARD
  # to generate documentation, but this does not cause problems.
  include Gaffe::Errors
  
  # Override Gaffe error layout with normal application layout.
  layout 'application'
  
  # Render the correct template based on the exception
  # ÒstandardÓ code.  Eg. For a 404 error, the `errors/not_found`
  # template will be rendered.
  def show
    # Set current_user from the sessions hash if there is one.
    current_user
    # @rescue_response and @exception are both available,
    # but unused variables.
    # @rescue_response is the name of the error for a typical error.
    # @exception contains the original raised error message.
    respond_to do |format|
      format.html { render status: @status_code }
      format.json {
        render json: {error: "Internal server error; please try again later."}, status: 500
        }
    end
  end
end
