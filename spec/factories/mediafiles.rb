Factory.define :mediafile do |a|
  a.account { Factory(:account) }
end

Factory.define :mediafile_with_attachment, :parent => :mediafile do |m|
  m.file  { File.new(File.join(RAILS_ROOT, 'spec', 'fixtures', 'test-jpg.jpg')) }
end

Factory.define :detailed_mediafile, :parent => :mediafile_with_attachment do |m|
  m.sequence(:title)    { |n| "Test title ##{n}" }
  m.description         "Test description of this mediafile."
  m.date                Time.now.to_date
end

Factory.define :image, :parent => :mediafile, :class => "Image" do |i|
  i.settings { { 
            "thumb" => ['100>', 'jpg'],  
            "small" => ['250>', 'jpg'],
            "medium" => ['440>', 'jpg'],
            "large" => ['800>', 'jpg']
  } }
  i.file  { File.new(File.join(RAILS_ROOT, 'spec', 'fixtures', 'test-jpg.jpg')) }
end 

Factory.define :audiofile, :parent => :mediafile, :class => "Audiofile" do |a|
  a.file  { File.new(File.join(RAILS_ROOT, 'spec', 'fixtures', 'test-mp3.mp3')) }
end
