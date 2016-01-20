# This is called the "questions" controller, but is reffered to as
# the "settings" page in the app because it also has the repopulate
# methods.
class QuestionsController < ApplicationController
  before_action :check_login
  before_action :set_question, only: [:edit, :update, :destroy]

  # CanCan checks
  authorize_resource

  # GET /questions
  def index
    @active_questions = Question.active.chronological.to_a
  end

  # GET /questions/1/edit
  def edit
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # PATCH/PUT /questions/1
  def update
    if @question.update(question_params)
      redirect_to admin_path, notice: 'Question was successfully updated.'
    else
      render :edit
    end
  end

  # POST /quesitons
  def create
    @question = Question.new(question_params)
    if @question.save
      redirect_to admin_path, notice: 'Question was successfully created.'
    else
      render :new
    end
  end

  # DELETE /questions/1
  def destroy
    # Don't actually destroy the question; we need to preserve it for existing keys.
    @question.inactivate
    redirect_to admin_path, notice: 'Question was successfully deleted.'
  end

  # PATCH /repopulate_columns
  def repopulate_columns
    if Column.repopulate
      redirect_to questions_path, notice: "The columns in the system were successfully updated."
    else
      redirect_to questions_path, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end

  # PATCH /repopulate_organizations
  def repopulate_organizations
    if Organization.repopulate
      redirect_to questions_path, notice: "The organizations look-up table was successfully updated."
    else
      redirect_to questions_path, alert: "The request to CollegiateLink failed. Please try again later."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:message, :required)
    end
end
