#Tells the server where to find ImageMagick
#Paperclip.options[:command_path] = "/usr/local/bin/"
Paperclip.options[:swallow_stderr] = false

#Load custom Paperclip interpolation
Paperclip::Attachment.interpolations[:account] = proc do |attachment, style|
  attachment.instance.account.name
end