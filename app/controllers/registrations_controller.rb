class RegistrationsController < DeviseTokenAuth::RegistrationsController
  def create
    super do |resource|
      create_avatar(resource) if resource.id && params[:avatar_content]
      resource
    end
  end

  protected

  def render_create_error_invalid_avatar
    render json: {
      status: 'error',
      errors: ['invalid avatar']
    }, status: 422
  end

  def render_create_error_exception(e)
    render json: {
      status: 'error',
      errors: [e.message]
    }, status: 422
  end

  private

  def create_avatar(user)
    begin
      User.transaction do
        @image = Image.new
        @image.creator_id = user.id
        @image.user = user

        if @image.save
          avatar_params = params.require(:avatar_content).permit(:content, :content_type)
          original = ImageContent.new
          # to fix: need to set content_type before content
          original.content_type = avatar_params[:content_type]
          original.content = avatar_params[:content]

          contents = ImageContentCreator.new(@image, original).build_contents
          if contents.save!
            return true
          end
        end

        render_create_error_invalid_avatar
      end
    rescue => e
      render_create_error_exception(e)
    end
  end

end
