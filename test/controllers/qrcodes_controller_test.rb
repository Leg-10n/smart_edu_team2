require "test_helper"

class QrcodesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "should not be able to show qr by non-students" do
    [ :teacherA, :adminA, :one ].each do |user|
      sign_in(user)
      get qrcodes_url
      assert_redirected_to root_path
      assert_equal "You must have role [ student ] to access the requested page.", flash[:alert]
    end
  end

  test "should not be able to access qr scanner by non-teacher" do
    [ :studentA, :adminA, :one ].each do |user|
      sign_in(user)
      get scan_qr_url
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end
end
