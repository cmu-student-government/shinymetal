class UserKeysController < ApplicationController
  before_action :set_user_key, only: [:show, :edit, :update, :destroy]

  # GET /user_keys
  # GET /user_keys.json
  def index
    @user_keys = UserKey.all
  end

  # GET /user_keys/1
  # GET /user_keys/1.json
  def show
  end

  # GET /user_keys/new
  def new
    @user_key = UserKey.new
  end

  # GET /user_keys/1/edit
  def edit
  end

  # POST /user_keys
  # POST /user_keys.json
  def create
    @user_key = UserKey.new(user_key_params)

    respond_to do |format|
      if @user_key.save
        format.html { redirect_to @user_key, notice: 'User key was successfully created.' }
        format.json { render :show, status: :created, location: @user_key }
      else
        format.html { render :new }
        format.json { render json: @user_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_keys/1
  # PATCH/PUT /user_keys/1.json
  def update
    respond_to do |format|
      if @user_key.update(user_key_params)
        format.html { redirect_to @user_key, notice: 'User key was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_key }
      else
        format.html { render :edit }
        format.json { render json: @user_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_keys/1
  # DELETE /user_keys/1.json
  def destroy
    @user_key.destroy
    respond_to do |format|
      format.html { redirect_to user_keys_url, notice: 'User key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_key
      @user_key = UserKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_key_params
      params.require(:user_key).permit(:status, :expiration_date, :application_text, :user_key_filter_ids => [])
    end
end
