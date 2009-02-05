require 'test_helper'

class WaxingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:waxings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create waxing" do
    assert_difference('Waxing.count') do
      post :create, :waxing => { }
    end

    assert_redirected_to waxing_path(assigns(:waxing))
  end

  test "should show waxing" do
    get :show, :id => waxings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => waxings(:one).id
    assert_response :success
  end

  test "should update waxing" do
    put :update, :id => waxings(:one).id, :waxing => { }
    assert_redirected_to waxing_path(assigns(:waxing))
  end

  test "should destroy waxing" do
    assert_difference('Waxing.count', -1) do
      delete :destroy, :id => waxings(:one).id
    end

    assert_redirected_to waxings_path
  end
end
