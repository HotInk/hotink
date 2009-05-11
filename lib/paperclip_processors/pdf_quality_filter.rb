# Very simple Paperclip processor that converts uploaded PDF to a specific PDF predifined quality settings configuration.
# The conversion can take several minutes, even on a fast machine, so please be patient. Note that the output PDF will
# not be rasterized, as with ImageMagick. This processor relys on an optional ImageMagick dependency called Ghostscript 
# (install with "port install ghostscript").
# 
# The following options are available: "screen", "ebook", "printer", "prepress", and "default"
# For more information on what those options mean, see: http://www.ghostscript.com/~ghostgum/pdftips.htm#distparam\n
# 
# by Chris Dinn <chris@hotink.net> - May 2009

module Paperclip
  
  # Handles compressing PDFs into a download-friendly format.
  class PdfQualityFilter < Processor
    
    # Creates a screen quality pdf version of the +file+ given.
    def initialize file, options = {}, attachment = nil
      super
      raise ArgumentError, :message => "No pdf quality was specified, please add the :quality option to your PdfQualityFilter style hash." unless options[:quality]
      @quality = options[:quality]==true ? 'screen' :  options[:quality].to_s
      @file = file
      @whiny  = options[:whiny].nil? ? true : options[:whiny]
      
    end
    
    # Performs the conversion of the +file+ into a screen-quality pdf. Returns a Tempfile
    # that contains the new quality filtered pdf.
    def make
      src = @file
      dst = Tempfile.new([@basename, 'pdf' ].compact.join("."))
      dst.binmode

      command = <<-end_command
        -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dCompatabilityLevel=1.3 
        -dPDFSETTINGS=/#{@quality} -sOutputFile="#{ File.expand_path(dst.path) }" "#{ File.expand_path(src.path) }"
      end_command

      begin
        success = Paperclip.run("gs", command.gsub(/\s+/, " "))
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the quality filtered pdf for #{@basename}" if @whiny
      end

      dst
    end
    
  end
end
