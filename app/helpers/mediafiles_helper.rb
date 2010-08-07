module MediafilesHelper
  
  def title_for(mediafile)
    if mediafile.title.blank?
      if mediafile.is_a? Audiofile
        if mediafile.song_title.blank?
          mediafile.file_file_name
        else
          if mediafile.artist.blank?
            mediafile.song_title
          else
            mediafile.song_title + " - " + mediafile.artist
          end
        end
      else
        mediafile.file_file_name
      end
    else
      mediafile.title
    end
  end
  
end