
Factory.sequence :email do |n|
  "somebody#{n}@example.com"
end

Factory.define :account do |a|
  a.name "onlinejournalgazette"
  a.time_zone "Eastern Time (US & Canada)"
end

Factory.define :article do |a|
  a.date Time.now
  a.account {|a| a.association(:account) }
end

Factory.define :post do |f|
  f.title    'undef toggle!'
  f.approved true
  # Lazy attribute blocks are passed a proxy object that can be used to
  # generate associations lazily. The object generated will depend on which
  # build strategy you're using. For example, if you generate an unsaved post,
  # this will generate an unsaved user as well.
  f.author   {|a| a.association(:user) }
end

# Let's define a factory with a custom classname:
Factory.define :admin_user, :class => User do |f|
  f.login 'chhrisdinn'
  f.email      { Factory.next(:email) }
end