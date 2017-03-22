class Thing < ActiveRecord::Base
  include Protectable
  validates :name, :presence=>true

  has_many :thing_images, inverse_of: :thing, dependent: :destroy

  scope :not_linked, ->(image) { where.not(:id=>ThingImage.select(:thing_id)
                                                          .where(:image=>image)) }
  def roles
    Role.where(mname: Thing, mid: self.id)
  end

  def members
    roles.members
  end

  def organizers
    roles.organizers
  end

end
