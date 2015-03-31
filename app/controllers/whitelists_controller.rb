class WhitelistsController < ApplicationController
  before_action :check_login
  before_action :set_whitelist, only: [:edit, :update, :destroy]
  before_action :set_user_key
  
  # CanCan checks; onyl admin can see any of this
  authorize_resource

  # No index or show, just destroy, edit, update, new, create
  
  # GET /user_keys/1/whitelists/new
  def new
    @whitelist = Whitelist.new(user_key: @user_key)
  end
  
  # GET /user_keys/1/whitelists/1/edit
  def edit
  end

  # PATCH/PUT /user_keys/1/whitelists/1
  def update
    if @whitelist.update(whitelist_params)
      redirect_to @user_key, notice: 'Whitelist was successfully updated.'
    else
      render :edit
    end
  end
  
  # POST /user_keys/1/whitelists
  def create
    # Set whitelists's key to be the current key
    @whitelist = Whitelist.new(whitelist_params)
    @whitelist.user_key_id = @user_key.id
    if @whitelist.save
      redirect_to @user_key, notice: 'Whitelist was successfully created.'
    else
      render :new
    end
  end
  
  # DELETE /user_keys/1
  def destroy
    @whitelist.destroy
    redirect_to @user_key, notice: 'Whitelist was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_key
      @user_key = UserKey.find(params[:user_key_id])
    end
    
    def set_whitelist
      @whitelist = Whitelist.find(params[:id])
    end
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def whitelist_params
      params.require(:whitelist).permit( :filter_ids => [] )
    end
end
