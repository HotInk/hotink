require 'test_helper'

class AuthorshipsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:authorships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create authorship" do
    assert_difference('Authorship.count') do
      post :create, :authorship => { }
    end

    assert_redirected_to authorship_path(assigns(:authorship))
  end

  test "should show authorship" do
    get :show, :id => authorships(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => authorships(:one).id
    assert_response :success
  end

  test "should update authorship" do
    put :update, :id => authorships(:one).id, :authorship => { }
    assert_redirected_to authorship_path(assigns(:authorship))
  end

  test "should destroy authorship" do
    assert_difference('Authorship.count', -1) do
      delete :destroy, :id => authorships(:one).id
    end

    assert_redirected_to authorships_path
  end
end
