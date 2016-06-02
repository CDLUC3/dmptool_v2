FactoryGirl.define do
  
  factory :fg_user, class: User do
    first_name "General" 
    last_name "User"
    password "secreT1234"
    password_confirmation "secreT1234"
    email "dmptool-test-user@ucop.edu"
  end
  
  factory :fg_inst_admin, class: User do
    first_name "Institutional" 
    last_name "Admin"
    password "secreT1234"
    password_confirmation "secreT1234"
    email "dmptool-test-instadmin@ucop.edu"
  end
  
  factory :fg_dmp_admin, class: User do
    first_name "DMPTool" 
    last_name "Admin"
    password "secreT1234"
    password_confirmation "secreT1234"
    email "dmptool-test-dmpadmin@ucop.edu"
  end
end