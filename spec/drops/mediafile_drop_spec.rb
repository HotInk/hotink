require 'spec_helper'

describe MediafileDrop do
  include ActionView::Helpers::NumberHelper
  before do
    @mediafile = Factory(:mediafile, :title => "Test media", :description => "Mediafile created for testing")
    @mediafile.authors_list = "Author 1, Author 2"
  end
  
  it "should make basic attributes available" do
    output = Liquid::Template.parse( ' {{ mediafile.url }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.url(:original)} "
    
    output = Liquid::Template.parse( ' {{ mediafile.id }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.id} "
    
    output = Liquid::Template.parse( ' {{ mediafile.authors_list }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.authors_list} "
    
    output = Liquid::Template.parse( ' {{ mediafile.date }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.date} "
    
    output = Liquid::Template.parse( ' {{ mediafile.title }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.title} "
    
    output = Liquid::Template.parse( ' {{ mediafile.description }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{@mediafile.description} "
  end
  
  it "should return a user-readable file size" do
    output = Liquid::Template.parse( ' {{ mediafile.file_size }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
    output.should == " #{number_to_human_size(@mediafile.file_size)} "
  end
  
  describe "caption" do
    it "should make basic caption available if supplied" do
      output = Liquid::Template.parse( ' {{ mediafile.caption }} '  ).render('mediafile' => MediafileDrop.new(@mediafile, :caption => "Test caption"))
      output.should == " Test caption "
    end
    
    it "should display blank caption cleanly" do
      output = Liquid::Template.parse( ' {{ mediafile.caption }} '  ).render('mediafile' => MediafileDrop.new(@mediafile, :caption => nil))
      output.should == "  "
    end
  end
  
  describe "media type" do
    it "should return the mediafile's type" do
      output = Liquid::Template.parse( ' {{ mediafile.type }} '  ).render('mediafile' => MediafileDrop.new(@mediafile))
      output.should == " File "
      
      image = Factory(:image)
      output = Liquid::Template.parse( ' {{ mediafile.type }} '  ).render('mediafile' => MediafileDrop.new(image))
      output.should == " Image "
      
      audiofile = Factory(:audiofile)
      output = Liquid::Template.parse( ' {{ mediafile.type }} '  ).render('mediafile' => MediafileDrop.new(audiofile))
      output.should == " Audiofile "
    end
    
    describe "media type identification" do
      before do
        @image = Factory(:image)
        @audiofile = Factory(:audiofile)
      end
      
      it "should properly identify mediafiles" do
        output = Liquid::Template.parse( '{% if mediafile.file? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@mediafile))
        output.should == " PASS "

        output = Liquid::Template.parse( '{% if mediafile.file? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@image))
        output.should == " FAIL "
      end
      
      it "should properly identify images" do
        output = Liquid::Template.parse( '{% if mediafile.image? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@image))
        output.should == " PASS "

        output = Liquid::Template.parse( '{% if mediafile.image? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@audiofile))
        output.should == " FAIL "
      end
      
      it "should properly identify audiofiles" do
        output = Liquid::Template.parse( '{% if mediafile.audiofile? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@audiofile))
        output.should == " PASS "

        output = Liquid::Template.parse( '{% if mediafile.audiofile? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@image))
        output.should == " FAIL "
      end
    end
  end

  describe "images" do
    before do
      @image = Factory(:horizontal_image)
    end
    
    it "should return width" do
      output = Liquid::Template.parse( ' {{ mediafile.width }} '  ).render('mediafile' => MediafileDrop.new(@image))
      output.should == " #{@image.width} "
    end
    
    it "should return height" do
      output = Liquid::Template.parse( ' {{ mediafile.height }} '  ).render('mediafile' => MediafileDrop.new(@image))
      output.should == " #{@image.height} "
    end
    
    describe "sizes" do
      it "should know the various image size urls" do
         output = Liquid::Template.parse( ' {{ mediafile.image_url["original"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:original) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["thumb"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:thumb) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["small"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:small) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["medium"]}} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:medium) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["large"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:large) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["system_default"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:system_default) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["system_thumb"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:system_thumb) } "

         output = Liquid::Template.parse( ' {{ mediafile.image_url["system_icon"] }} '  ).render('mediafile' => MediafileDrop.new(@image))
         output.should == " #{ @image.url(:system_icon) } "
       end
    end
    
    describe "orientation" do
      before do
        @horizontal_image = @image
        @vertical_image = Factory(:vertical_image)
      end
      
      it "should properly identify vertical images" do
        output = Liquid::Template.parse( '{% if mediafile.vertical? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@vertical_image))
        output.should == " PASS "
        
        output = Liquid::Template.parse( '{% if mediafile.vertical? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@horizontal_image))
        output.should == " FAIL "
      end
      
      it "should properly identify horizontal images" do
        output = Liquid::Template.parse( '{% if mediafile.horizontal? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@horizontal_image))
        output.should == " PASS "
        
        output = Liquid::Template.parse( '{% if mediafile.horizontal? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@vertical_image))
        output.should == " FAIL "
      end
      
      it "should not misidentify non-image files" do
        output = Liquid::Template.parse( '{% if mediafile.horizontal? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@mediafile))
        output.should == " FAIL "
        
        output = Liquid::Template.parse( '{% if mediafile.vertical? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(@mediafile))
        output.should == " FAIL "
        
        audiofile = Factory(:audiofile)
        output = Liquid::Template.parse( '{% if mediafile.horizontal? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(audiofile))
        output.should == " FAIL "
        
        output = Liquid::Template.parse( '{% if mediafile.vertical? %} PASS {% else %} FAIL {% endif %}'  ).render('mediafile' => MediafileDrop.new(audiofile))
        output.should == " FAIL "
      end
    end
  end
end
