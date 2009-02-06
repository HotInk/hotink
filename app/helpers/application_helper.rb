# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Re-create link_to with full functionality but providing button code wrapping
   def button_link_to(*args, &block)
         if block_given?
           options      = args.first || {}
           html_options = args.second
           concat(link_to(capture(&block), options, html_options))
         else
           name         = args.first
           options      = args.second || {}
           html_options = args.third

           url = url_for(options)

           # This is the only difference in this function from link_to.
           # Add the button class to any other sent along.
           html_options.default = ""
           html_options[:class] = "btn " + html_options[:class]

           if html_options
             html_options = html_options.stringify_keys
             href = html_options['href']
             convert_options_to_javascript!(html_options, url)
             tag_options = tag_options(html_options)
           else
             tag_options = nil
           end

           href_attr = "href=\"#{url}\"" unless href
           "<a #{href_attr}#{tag_options}><span><span>#{name || url}</span></span></a>"
       end

   end

   def button_link_to_function(name, *args, &block)
       html_options = args.extract_options!.symbolize_keys

       html_options.default = ""
       html_options[:class] = html_options[:class] + " btn"

       function = block_given? ? update_page(&block) : args[0] || ''
       onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
       href = html_options[:href] || '#'

       content_tag(:a,"<span><span>" + name + "</span></span>", html_options.merge(:href => href, :onclick => onclick))
   end

   def button_link_to_remote(name, options = {}, html_options = nil)
       button_link_to_function(name, remote_function(options), html_options || options.delete(:html))
   end
  
end
