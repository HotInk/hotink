require 'spec_helper'

describe Audiofile do
  include ActionView::Helpers::NumberHelper
  it "should build audiofile-specific xml representation" do
    audiofile = Factory(:audiofile)
    audiofile.to_xml.should include(number_to_human_size(audiofile.file_file_size))
    audiofile.to_xml.should include(audiofile.file.url)
    audiofile.to_xml.should include(audiofile.date.to_s)
  end
end
