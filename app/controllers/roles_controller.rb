class RolesController < ApplicationController
  before_action :set_role, only: [:show, :update, :destroy]

  def index
    @roles = Role.all
  end

  def show
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      render :show, status: :created, location: @role
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def update
    @role = Role.find(params[:id])

    if @role.update(role_params)
      head :no_content
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy

    head :no_content
  end

  private

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:role_name, :user_id)
    end
end
