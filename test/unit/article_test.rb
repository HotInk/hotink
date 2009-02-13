require 'test_helper'

class ArticleTest < ActiveSupport::TestCase

  def test_display_title
    assert_equal articles(:one).display_title, "Simon Fraser union battle"
  end

  def test_no_title_display_title
    assert_equal articles(:two).display_title, "(no headline)"
  end
  
end
