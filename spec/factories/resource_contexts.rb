# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resource_context do
    institution nil
    requirements_template nil
    resource_template nil
    requirement nil
  end
end
