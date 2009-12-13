Factory.define :account do |a|
  a.sequence(:name) { |n| "Account \##{n}" }
  a.time_zone "What time?"
end

Factory.define :article do |a|
  a.account { Factory(:account) }
end

Factory.define :basic_article, :class => Article do |ba|
  ba.account { Factory(:account) }
  ba.sequence(:title) { |n| "An article about \##{n}"}
end