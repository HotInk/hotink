xml.instruct!
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/",  "xmlns:media" => "http://search.yahoo.com/mrss/") do
  xml.channel do
    xml.title @feed_title
    xml.link @account.site_url.blank? ? root_url(:subdomain => @account.name) : @account.site_url
    xml.description ""
    xml.language "en-gb"

    for article in @articles
      xml.item do
        xml.pubDate article.published_at.rfc822
        xml.title h(article.title)
        xml.link "http://" + request.host_with_port + "/articles/#{article.id}"
        xml.guid "http://" + request.host_with_port + "/articles/#{article.id}"
        xml.description do
          xml << "<![CDATA["
          if article.subtitle
              xml << "<p><strong>#{article.subtitle}</strong></h2>"
          end
          if article.section
            xml << "<p>#{article.section.name}</strong></p>"
          end
          if article.authors_list
            xml << "<p><strong>#{article.authors_list}</strong></p>"
          end
          xml << markdown(article.bodytext)
          xml << "]]>"
        end
      end
    end
  end
end
