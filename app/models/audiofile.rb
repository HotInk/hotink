class Audiofile < Mediafile
  
  # MP3 info
  
  def length
    Mp3Info.open(file.path(:original)) do |info|
      info.length.to_i
    end
  end
  
  def artist
    Mp3Info.open(file.path(:original)) do |info|
      info.tag.artist
    end
  end
  
  def song_title
    Mp3Info.open(file.path(:original)) do |info|
      info.tag.title
    end
  end
  
  def album
    Mp3Info.open(file.path(:original)) do |info|
      info.tag.album
    end
  end
  
  def release_year
    Mp3Info.open(file.path(:original)) do |info|
      info.tag.year
    end
  end
  
  # Identity

  def audiofile?
    true
  end
  
  def file?
    false
  end
  
  
  def to_xml(options = {})
    
    caption = options[:caption] || self.description
    
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.mediafile do
       xml.tag!( :title, self.title )
       xml.tag!( :caption, caption)
       xml.tag!( :mediafile_type, self.class.name || "Mediafile" )
       xml.tag!( :date, self.date )
       xml.tag!( :authors_list, self.authors_list )
       xml.url do
         xml.tag!(:original, self.file.url)
       end
       xml.tag!( :content_type, self.file_content_type )
       xml.tag!( :original_file_size, number_to_human_size(self.file_file_size) )
       xml.tag!( :id, self.id )
     end
  end
end
