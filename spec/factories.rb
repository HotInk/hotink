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
###

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

Factory.define :mediafile do |a|
  a.account { Factory(:account) }
end

Factory.define :email_template do |et|
  et.sequence(:name) { |n| "Email template ##{n}" }
  et.account { Factory(:account) }
end

Factory.define :email_template_with_articles, :parent => :email_template do |et|
  et.html "<h1>Test</h1><ol>{% for article in articles %}<li>{{ article.title }}</li>{% endfor %}</ol>"
  et.plaintext "Test\n====\n\n{% for article in articles %}-- {{ article.title }}\n{% endfor %}"
end
