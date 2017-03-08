require_relative '../support/image_content_helper.rb'
FactoryGirl.define do
  factory :image_content do
    content_type "image/jpg"
        #default to the original size when we generate just attributes
    sequence(:content) {|idx|
      File.open(ImageContentHelper.sample_filepath,"rb") { |f|
        image=StringIO.new(f.read)
        image=ImageContentCreator.annotate(idx, image)
        Base64.encode64(image)
      }
    }

    trait :random_avatar do
      content do
        color = Faker::Color.hsl_color

        MiniMagick::Tool::Convert.new do |c|
          c.size "30x20"
          c.gradient "hsl(#{color[0]}, #{color[1]*100}%, #{color[2]*100}%)"
          c << "tmp/avatar.jpg"
        end
        image = File.open('tmp/avatar.jpg').read
        Base64.encode64(image)
      end
    end
  end
end
