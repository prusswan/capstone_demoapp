class Things::RolesController < ApplicationController
  before_action :set_thing
  before_action :set_role, only: [:show, :update, :destroy]

  before_action :authenticate_user! #, only: [:index, :create, :update, :destroy, ]
  after_action :verify_authorized

  def index
    authorize @thing, :index?
    @roles = @thing.roles
  end

  def members
    authorize @thing, :get_members?
    @roles = @thing.members

    render :index
  end

  def organizers
    authorize @thing, :get_organizers?
    @roles = @thing.organizers

    render :index
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
    def set_thing
      @thing = Thing.find(params[:thing_id])
    end

    def set_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:role_name, :user_id)
    end
end
