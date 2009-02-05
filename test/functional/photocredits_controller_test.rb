require 'test_helper'

class PhotocreditsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:photocredits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create photocredit" do
    assert_difference('Photocredit.count') do
      post :create, :photocredit => { }
    end

    assert_redirected_to photocredit_path(assigns(:photocredit))
  end

  test "should show photocredit" do
    get :show, :id => photocredits(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => photocredits(:one).id
    assert_response :success
  end

  test "should update photocredit" do
    put :update, :id => photocredits(:one).id, :photocredit => { }
    assert_redirected_to photocredit_path(assigns(:photocredit))
  end

  test "should destroy photocredit" do
    assert_difference('Photocredit.count', -1) do
      delete :destroy, :id => photocredits(:one).id
    end

    assert_redirected_to photocredits_path
  end
end
