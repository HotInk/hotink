Factory.define :account do |a|
  a.sequence(:name) { |n| "Account \##{n}" }
  a.time_zone "What time?"
end

Factory.define :article do |a|
  a.account { Factory(:account) }
end

Factory.sequence :article_title do |n|
  "The truth about \##{n}"
end

Factory.define :basic_article, :parent => :article do |ba|
  ba.title   { Factory.next(:article_title) }
end

Factory.define :published_article, :parent => :basic_article do |ba|
  ba.status         "published"
  ba.published_at   Time.now
end

Factory.define :detailed_article, :parent => :article do |da|
  da.title          { Factory.next(:article_title) }
  da.subtitle       "Get a detailed look (subtitle)"
  da.authors        { (1..3).collect{ Factory(:author) } }
  da.bodytext       "Wow. I **cannot** believe *the truth*."
  da.status         "published"
  da.published_at   Time.now
end

Factory.define :author do |a|
  a.sequence(:name) { |n| "Author ##{n}" }
  a.account { Factory(:account) }
end