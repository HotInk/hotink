require 'test_helper'

class AudiofilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audiofiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create audiofile" do
    assert_difference('Audiofile.count') do
      post :create, :audiofile => { }
    end

    assert_redirected_to audiofile_path(assigns(:audiofile))
  end

  test "should show audiofile" do
    get :show, :id => audiofiles(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => audiofiles(:one).id
    assert_response :success
  end

  test "should update audiofile" do
    put :update, :id => audiofiles(:one).id, :audiofile => { }
    assert_redirected_to audiofile_path(assigns(:audiofile))
  end

  test "should destroy audiofile" do
    assert_difference('Audiofile.count', -1) do
      delete :destroy, :id => audiofiles(:one).id
    end

    assert_redirected_to audiofiles_path
  end
end
