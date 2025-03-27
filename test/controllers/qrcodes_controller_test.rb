require "test_helper"

class QrcodesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "should not be able to show qr by non-students" do
      sign_in(:teacherA) # Ensure this references a symbol, not a User object
      get qrcodes_url
      assert_redirected_to root_path
      assert_equal "You must have role [ student ] to access the requested page.", flash[:alert]
    end

  test "should not be able to access qr scanner by non-teacher" do
    [ :studentA, :adminA ].each do |user|
      sign_in(user)  # Students must exist in users.yml, not students.yml
      get scan_qr_url
      assert_redirected_to root_path
      assert_equal "You must have role [ teacher ] to access the requested page.", flash[:alert]
    end
  end
end
