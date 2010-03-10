Factory.define :invitation do |i|
  i.sequence(:email)  { |n| "invite#{n}@invitation.ca"  }
  i.user  { Factory(:user) }
  i.redeemed  false
end

Factory.define :user_invitation, :class => "UserInvitation", :parent => :invitation do |i|
  i.account { Factory(:account) }
end

Factory.define :account_invitation, :class => "AccountInvitation", :parent => :invitation do |i|
  
end

Factory.define :account do |a|
  a.sequence(:name) { |n| "Account \##{n}" }
  a.time_zone "What time?"
end

Factory.define :user do |u|
  u.sequence(:name)  { |n| "User ##{n}" }
  u.sequence(:email) { |n| "useremail#{n}@example.com"}
  u.sequence(:login) { |n| "user#{n}" }
  u.password "password_1"
  u.password_confirmation "password_1"
end

Factory.define :waxing do |w|
  w.document { Factory(:article) }
  w.mediafile { Factory(:mediafile) }
end

###

Factory.define :category do |c|
  c.sequence(:name)  { |n| "Category ##{n}" }
  c.account { Factory(:account) }
  c.active true
end

Factory.define :inactive_category, :parent => :category do |c|
  c.active false
end

Factory.define :author do |a|
  a.sequence(:name) { |n| "Author ##{n}" }
  a.account { Factory(:account) }
end

Factory.define :blog do |b|
  b.sequence(:title)  { |n| "Blog ##{n}" }
  b.account { Factory(:account)}
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

Factory.define :sso_consumer do |consumer|
  consumer.sequence(:name) { |n| "Consumer #{n}" }
  consumer.sequence(:url) { |n| "http://sso#{n}.consumerapp.com/sso"}
end