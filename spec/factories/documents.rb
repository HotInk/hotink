Factory.define :document do |d|
  d.account { Factory(:account) }
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
  ba.status         "Published"
  ba.published_at   Time.now
  ba.created_at     1.day.ago
end

Factory.define :detailed_article, :parent => :article do |a|
  a.title          { Factory.next(:article_title) }
  a.subtitle       "Get a detailed look (subtitle)"
  a.authors        { (1..3).collect{ Factory(:author) } }
  a.bodytext       "Wow. I **cannot** believe *the truth*."
  a.status         "Published"
  a.published_at   Time.now
  a.created_at     1.day.ago
end

Factory.define :draft_article, :parent => :article do |a|
  a.title          { Factory.next(:article_title) }
  a.subtitle       "Get a detailed look (subtitle)"
  a.authors        { (1..3).collect{ Factory(:author) } }
  a.bodytext       "Wow. I **cannot** believe *the truth*."
  a.created_at      1.day.ago
end

Factory.define :scheduled_article, :parent => :article do |a|
  a.title          { Factory.next(:article_title) }
  a.subtitle       "Get a detailed look (subtitle)"
  a.authors        { (1..3).collect{ Factory(:author) } }
  a.bodytext       "Wow. I **cannot** believe *the truth*."
  a.status         "Published"
  a.published_at   Time.now + 1.week
  a.created_at     1.day.ago
end

Factory.define :detailed_article_with_mediafiles, :parent => :detailed_article do |a|
  a.mediafiles { (1..3).collect{ Factory(:detailed_mediafile)  } }
end

Factory.define :entry do |e|
  e.account { Factory(:account) }
  e.blog { |f| Factory(:blog, :account => f.account) }
end

Factory.define :draft_entry, :parent => :entry do |e|
  e.title { Factory.next(:article_title) }
end

Factory.define :published_entry, :parent => :entry do |e|
  e.status         "Published"
  e.published_at   Time.now
  e.created_at     1.day.ago
end

Factory.define :detailed_entry, :class => "Entry", :parent => :detailed_article do |e|
  e.account { Factory(:account) }
  e.blog { |f| Factory(:blog, :account => f.account) }
end

Factory.define :scheduled_entry, :class => "Entry", :parent => :scheduled_article do |e|
  e.account { Factory(:account) }
  e.blog { |f| Factory(:blog, :account => f.account) }
end