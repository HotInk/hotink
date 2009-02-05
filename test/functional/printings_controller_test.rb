require 'test_helper'

class PrintingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:printings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create printing" do
    assert_difference('Printing.count') do
      post :create, :printing => { }
    end

    assert_redirected_to printing_path(assigns(:printing))
  end

  test "should show printing" do
    get :show, :id => printings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => printings(:one).id
    assert_response :success
  end

  test "should update printing" do
    put :update, :id => printings(:one).id, :printing => { }
    assert_redirected_to printing_path(assigns(:printing))
  end

  test "should destroy printing" do
    assert_difference('Printing.count', -1) do
      delete :destroy, :id => printings(:one).id
    end

    assert_redirected_to printings_path
  end
end
