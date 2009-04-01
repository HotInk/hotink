Factory.define :account do |a|
  a.name "onlinejournalgazette"
  a.time_zone "Eastern Time (US & Canada)"
end

Factory.define :article do |a|
  a.date Time.now
  a.account {|a| a.association(:account) }
end