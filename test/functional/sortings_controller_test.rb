require 'test_helper'

class SortingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sortings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sorting" do
    assert_difference('Sorting.count') do
      post :create, :sorting => { }
    end

    assert_redirected_to sorting_path(assigns(:sorting))
  end

  test "should show sorting" do
    get :show, :id => sortings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => sortings(:one).id
    assert_response :success
  end

  test "should update sorting" do
    put :update, :id => sortings(:one).id, :sorting => { }
    assert_redirected_to sorting_path(assigns(:sorting))
  end

  test "should destroy sorting" do
    assert_difference('Sorting.count', -1) do
      delete :destroy, :id => sortings(:one).id
    end

    assert_redirected_to sortings_path
  end
end
