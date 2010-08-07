require 'spec_helper'

describe MediafilesHelper do
  include MediafilesHelper
  
  it "should find title for audiofile" do
    audiofile = Factory(:audiofile, :title => nil)
    
    title_for(audiofile).should eql(audiofile.song_title + " - " + audiofile.artist )
    
    audiofile.update_attribute(:title, "This song's title")
    title_for(audiofile).should eql("This song's title")

    audiofile.update_attribute(:title, nil)    
    audiofile.stub!(:song_title).and_return(nil)
    title_for(audiofile).should eql(audiofile.file_file_name)
    
    mediafile = Factory(:mediafile)
    title_for(mediafile).should eql(mediafile.file_file_name)
    
    mediafile.update_attribute(:title, "A title here")
    title_for(mediafile).should eql("A title here")
  end
end
