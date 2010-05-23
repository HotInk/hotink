Factory.define :issue do |i|
  i.account { Factory(:account) }
  i.date { Time.now.to_date }
end

Factory.define :issue_being_processed, :parent => :issue do |i|
  i.processing true
end