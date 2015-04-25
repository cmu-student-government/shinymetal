# Manages pages which hold content unrelated to functionality.
# These pages are created the first time their urls are visited,
# and fetched from the database every time after that.
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
    # Get the home, contact, etc page
    def set_page
      @page = Page.find_or_create(params[:page_url])
      # Does this page exist? If not, raise 404 error.
      raise ActiveRecord::RecordNotFound unless @page
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:message)
    end
end
