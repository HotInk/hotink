class Audiofile < Mediafile

  def to_xml(options = {})
    
    caption = options[:caption] || self.description
    
     options[:indent] ||= 2
     xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
     xml.instruct! unless options[:skip_instruct]
     
     xml.mediafile do
       xml.tag!( :title, self.title )
       xml.tag!( :caption, caption)
       xml.tag!( :mediafile_type, self.type || "Mediafile" )
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
