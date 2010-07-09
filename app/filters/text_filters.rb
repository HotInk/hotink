module TextFilters
   def markdown(text)
     RDiscount.new(text).to_html
   end

   def shorten(input, words = 15, truncate_string = "…")
     if input.nil? 
       return ""
     end
     wordlist = input.split(/ /).reject{ |s| s == "" }
     l = words.to_i - 1
     l = 0 if l < 0
     shortened_string = wordlist.length > l ? wordlist[0..l].join(" ") : input 
     shortened_string = close_tags( shortened_string ).strip
     shortened_string += truncate_string if wordlist.length > l

     shortened_string
   end

   private

    def close_tags(text)
      open_tags = []
      text.scan(/\<([^\>\s\/]+)[^\>\/]*?\>/).each { |t| open_tags.unshift(t) }
      text.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t| open_tags.slice!(open_tags.index(t)) }
      open_tags.each {|t| text += "</#{t}>" }
      text
    end
end