class Things::RolesController < ApplicationController
  before_action :set_thing
  # before_action :set_role, only: [:show, :destroy]

  before_action :authenticate_user! #, only: [:index, :create, :update, :destroy, ]
  after_action :verify_authorized

  def index
    case params[:role_name]
    when Role::MEMBER
      return members
    when Role::ORGANIZER
      return organizers
    when Role::ORIGINATOR
      authorize @thing, :get_originators?
      @roles = Role.where(role_name: Role::ORIGINATOR, mname: Thing)
    else
      authorize @thing, :index?
      @roles = @thing.roles
    end
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
    user = User.find(params[:user_id])

    case params[:role_name]
    when Role::MEMBER
      authorize @thing, :modify_member?
      @role = user.add_role(Role::MEMBER, @thing)
    when Role::ORGANIZER
      authorize @thing, :modify_organizer?
      @role = user.add_role(Role::ORGANIZER, @thing)
    when Role::ORIGINATOR
      authorize @thing, :set_originator?
      @role = user.add_role(Role::ORIGINATOR, Thing)
    end

    # @role = Role.new(role_params)

    if @role.new_record? && @role.save
      render :show, status: :created, location: @role
    else
      @role.errors.add(:base, :role_exists, message: "user already has the role #{params[:role_name]}") if !@role.new_record?
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # def update
  #   @role = Role.find(params[:id])

  #   if @role.update(role_params)
  #     head :no_content
  #   else
  #     render json: @role.errors, status: :unprocessable_entity
  #   end
  # end

  def destroy
    user = User.find(params[:user_id])

    case params[:role_name]
    when Role::MEMBER
      authorize @thing, :modify_member?
      @role = user.add_role(Role::MEMBER, @thing)
    when Role::ORGANIZER
      authorize @thing, :modify_organizer?
      @role = user.add_role(Role::ORGANIZER, @thing)
    when Role::ORIGINATOR
      authorize @thing, :set_originator?
      @role = user.add_role(Role::ORIGINATOR, Thing)
    end

    @role.destroy

    head :no_content
  end

  private
    def set_thing
      @thing = Thing.find(params[:thing_id])
    end

    # def set_role
    #   @role = Role.find(params[:user_id])
    # end

    def role_params
      params.require(:role).permit(:role_name, :user_id)
    end
end
