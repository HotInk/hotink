require 'spec_helper'

describe Image do
  include ActionView::Helpers::NumberHelper
  it "should build image-specific xml representation" do
    image = Factory(:image, :settings => { 'small' => ['218>', 'jpg'] , 'medium' => ['458>', 'jpg'], 'thumb' => ['100x190>', 'jpg'], 'large' => ['800>', 'jpg'] })
    
    image.to_xml.should include(image.file.url(:original))
    image.to_xml.should include(image.file.url(:system_icon))
    image.to_xml.should include(image.file.url(:system_thumb))
    image.to_xml.should include(image.file.url(:system_default))
    image.to_xml.should include(image.file.url(:thumb))
    image.to_xml.should include(image.file.url(:small))
    image.to_xml.should include(image.file.url(:medium))
    image.to_xml.should include(image.file.url(:large))

    image.to_xml.should include(number_to_human_size(image.file_file_size))
  end
end
