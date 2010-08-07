require 'spec_helper'

describe Audiofile do
  include ActionView::Helpers::NumberHelper
  it "should build audiofile-specific xml representation" do
    audiofile = Factory(:audiofile)
    audiofile.to_xml.should include(number_to_human_size(audiofile.file_file_size))
    audiofile.to_xml.should include(audiofile.file.url)
    audiofile.to_xml.should include(audiofile.date.to_s)
  end
  
  describe "mp3 info" do
    before do
      @audiofile = Factory(:audiofile)
    end
       
    it "should know length, in seconds" do
      length = nil
      Mp3Info.open(@audiofile.file.path(:original)) do |info|
        length = info.length.to_i
      end
      @audiofile.length.should eql(length)
    end

    it "should know artist, if supplied" do
      artist = nil
      Mp3Info.open(@audiofile.file.path(:original)) do |info|
        artist = info.tag.artist
      end
      @audiofile.artist.should eql(artist)
    end
    
    it "should know song title, if supplied" do
      song_title = nil
      Mp3Info.open(@audiofile.file.path(:original)) do |info|
        song_title = info.tag.title
      end
      @audiofile.song_title.should eql(song_title)
    end
    
    it "should know album, if supplied" do
      album = nil
      Mp3Info.open(@audiofile.file.path(:original)) do |info|
        album = info.tag.album
      end
      @audiofile.album.should eql(album)
    end
    
    it "should know release year, if supplied" do
      release_year = nil
      Mp3Info.open(@audiofile.file.path(:original)) do |info|
        release_year = info.tag.year
      end
      @audiofile.release_year.should eql(release_year)
    end
  end
end
