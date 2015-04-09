class PagesController < ApplicationController
  before_action :set_page

  # CanCan checks; only admin can edit these pages.
  authorize_resource

  # GET /contact
  def show
  end

  # GET /contact/edit
  def edit
  end

  # PATCH/PUT /contact
  def update
    @page.update(page_params)
    redirect_to page_path(@page.url), notice: "The page was successfully updated."
  end
  
  private
    def set_page
      # Get the home, contact, etc page
      @page = Page.find_or_create(params[:page_url])
      # Does this page exist? If not, raise 404 error.
      raise ActiveRecord::RecordNotFound unless @page
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:message)
    end
end
