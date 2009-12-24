Factory.define :account do |a|
  a.sequence(:name) { |n| "Account \##{n}" }
  a.time_zone "What time?"
end

### Article factories
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
end

Factory.define :detailed_article, :parent => :article do |a|
  a.title          { Factory.next(:article_title) }
  a.subtitle       "Get a detailed look (subtitle)"
  a.authors        { (1..3).collect{ Factory(:author) } }
  a.bodytext       "Wow. I **cannot** believe *the truth*."
  a.status         "Published"
  a.published_at   Time.now
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
end

Factory.define :detailed_article_with_mediafiles, :parent => :detailed_article do |a|
  a.mediafiles { (1..3).collect{ Factory(:detailed_mediafile)  } }
end
###

### Mediafile factories
Factory.define :mediafile do |a|
  a.account { Factory(:account) }
end

Factory.define :mediafile_with_attachment, :parent => :mediafile do |m|
  m.file  { File.new(File.join(RAILS_ROOT, 'spec', 'fixtures', 'test-jpg.jpg')) }
end

Factory.define :detailed_mediafile, :parent => :mediafile_with_attachment do |m|
  m.sequence(:title)    { |n| "Test title ##{n}" }
  m.description         "Test description of this mediafile."
  m.date                Time.now.to_date
end

###

Factory.define :category do |c|
  c.sequence(:name)  { |n| "Category ##{n}" }
  c.account { Factory(:account) }
end

Factory.define :user do |u|
  u.sequence(:name)  { |n| "User ##{n}" }
  u.sequence(:email) { |n| "user#{n}@example.com"}
  u.sequence(:login) { |n| "user#{n}" }
  u.password "password_1"
  u.password_confirmation "password_1"
end

Factory.define :author do |a|
  a.sequence(:name) { |n| "Author ##{n}" }
  a.account { Factory(:account) }
end

Factory.define :checkout do |c|
  c.original_article { Factory(:article) }
  c.duplicate_article { Factory(:article) }
end

Factory.define :email_template do |et|
  et.sequence(:name) { |n| "Email template ##{n}" }
  et.account { Factory(:account) }
end

Factory.define :email_template_with_articles, :parent => :email_template do |et|
  et.html "<h1>Test</h1><p>{{ note }}</p><ol>{% for article in articles %}<li>{{ article.title }}</li>{% endfor %}</ol>"
  et.plaintext "Test\n====\n\n{{ note }}\n\n{% for article in articles %}-- {{ article.title }}\n{% endfor %}"
end
