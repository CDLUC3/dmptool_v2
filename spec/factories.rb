FactoryGirl.define do
  factory :user do
    institution_id 1
    sequence(:email) { |n| "test_email#{n}@ucop.edu" }
    sequence(:first_name) { |n| "First_Name#{n}" }
    sequence(:last_name) { |n| "Last_Name#{n}" }
  end
end