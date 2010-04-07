Factory.define :category do |c|
  c.sequence(:name)  { |n| "Category ##{n}" }
  c.account { Factory(:account) }
  c.active true
end

Factory.define :inactive_category, :parent => :category do |c|
  c.active false
end