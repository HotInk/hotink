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
