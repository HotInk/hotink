require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  def test_requires_name    
    a = Account.new
    a.save
    assert_not_nil a.errors[:name]
    a.name = "test"
    a.save
    assert a.errors.empty?
  end
  
  def test_account_must_be_unique
    a = Account.new
    a.name = "varsity" #fixture already has a varsity account
    a.save
    assert_not_nil a.errors[:name]
  end
  

end
