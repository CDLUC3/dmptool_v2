FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test_email#{n}@ucop.edu" }
    sequence(:first_name) { |n| "First_Name#{n}" }
    sequence(:last_name) { |n| "Last_Name#{n}" }

    association :institution
  end

  factory :institution do
    sequence(:full_name) { |n| "University of California - Campus#{n}" }
    sequence(:nickname) { |n| "UC#{n}" }
    desc "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur quis nisi metus, pulvinar pulvinar diam. Curabitur dignissim aliquet lectus in laoreet. Maecenas in commodo nunc. Quisque blandit auctor mollis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut quis nulla ut libero malesuada aliquam porttitor nec erat. Etiam suscipit lectus et ligula varius dictum. Vestibulum venenatis lectus eu leo mattis a dapibus elit congue."
    sequence(:contact_info) { |n| "Contact Person #{n}" }
    sequence(:contact_email) { |n| "contactemail#{n}@uc.edu" }
    sequence(:url) { |n| "http://moreinformation#{n}.edu" }
    sequence(:url_text) { |n| "More Information Page #{n}" }

    factory :shibb do
      sequence(:shib_entity_id) { |n| "urn:mace:incommon:uc#{n}.edu" }
      sequence(:shib_domain) { |n| "uc#{n}.edu" }
    end
  end

  factory :plan do
    sequence(:name) { |n| "Data Management Plan #{n}" }
    requirements_template_id 1
    solicitation_identifier "2138219"
    submission_deadline Time.now + 2.weeks
    visibility :public

    #association :requirements_template
  end

  factory :published_plan do
    sequence(:file_name) { |n| "file_name_#{n}.pdf" }
    visibility :public

    association :plan
  end

  factory :comment do
    visibility :owner
    value "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam porta risus nec est vehicula id ornare felis scelerisque. Aliquam erat."

    association :user
    association :plan

    factory :reviewer do
      visibility :reviewer
    end
  end

  factory :response do
    value "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam porta risus nec est vehicula id ornare felis scelerisque. Aliquam erat."
    requirement_id 1

    association :plan
    #association :requirement
    association :label
  end

  factory :label do
    desc "MB"
    group "data-size"
  end
end