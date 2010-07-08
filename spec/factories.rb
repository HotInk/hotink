
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

Factory.define :sso_consumer do |consumer|
  consumer.sequence(:name) { |n| "Consumer #{n}" }
  consumer.sequence(:url) { |n| "http://sso#{n}.consumerapp.com/sso"}
end

Factory.define :list do |l|
  l.account { Factory(:account) }
  l.sequence(:name) do |n|
    letter = "a"
    n.times do
      letter.next!
    end
    "List #{letter}"
  end
end

Factory.define :list_item do |li|
  li.document { Factory(:document) }
  li.list { Factory(:list) }
end
