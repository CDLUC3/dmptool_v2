namespace :db do
  desc 'Fill database with sample data.'
  task populate: :environment do
    make_institutions
    make_requirements_templates
    make_requirements
    make_tags
    make_additional_information
    make_sample_plans
    make_resource_templates
    make_resources
  end
end

def make_institutions
  @npi = Institution.where(full_name: 'Non-Partnered Institution',
                           nickname: 'NPI').first_or_create!

  @ucop = Institution.where(full_name: 'University of California, Office of the President',
                            nickname: 'UCOP',
                            contact_info: 'UC Curation Center',
                            contact_email: 'uc3_wrong@ucop.edu',
                            url: 'http://www.cdlib.org/uc3/dmp/',
                            url_text: 'UC3: Data management Planning',
                            shib_entity_id: 'urn:mace:incommon:ucop.edu',
                            shib_domain: 'ucop.edu').first_or_create!
end

def make_requirements_templates
  @requirements_templates = []

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Active/Public/Mandatory)',
                                                        active: true,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :public,
                                                        mandatory_review: true).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Inactive/Public/Mandatory)',
                                                        active: false,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :public,
                                                        mandatory_review: true).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Active/Institutional/Mandatory)',
                                                        active: true,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :institutional,
                                                        mandatory_review: true).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Inactive/Institutional/Mandatory)',
                                                        active: false,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :institutional,
                                                        mandatory_review: true).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Active/Public/Nonreviewed)',
                                                        active: true,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :public,
                                                        mandatory_review: false).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Inactive/Public/Nonreviewed)',
                                                        active: false,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :public,
                                                        mandatory_review: false).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Active/Institutional/Nonreviewed)',
                                                        active: true,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :institutional,
                                                        mandatory_review: false).first_or_create!

  @requirements_templates << RequirementsTemplate.where(institution_id: 1,
                                                        name: 'Requirements Template Test (Inactive/Institutional/Nonreviewed)',
                                                        active: false,
                                                        start_date: Time.now,
                                                        end_date: Time.now + 6.months,
                                                        visibility: :institutional,
                                                        mandatory_review: false).first_or_create!
end

def make_requirements
  requirement_types = [:text, :numeric, :date, :enum]
  obligation_types = [:mandatory, :mandatory_applicable, :recommended, :optional]

  @requirements_templates.each do |requirement_template|
    requirement_types.each do |requirement_type|
      obligation_types.each do |obligation_type|
        Requirement.where(requirements_template_id: requirement_template.id,
                          text_brief: 'This is the brief text.',
                          text_full: 'This is the full text. This is text/mandatory.',
                          requirement_type: requirement_type,
                          obligation: obligation_type,
                          default: 'This is the default answer.').first_or_create!
      end
    end
  end
end

def make_tags
  @requirements_templates.each do |requirement_template|
    Tag.where(requirements_template_id: requirement_template.id,
              tag: 'Tag1').first_or_create!

    Tag.where(requirements_template_id: requirement_template.id,
              tag: 'Tag2').first_or_create!
  end
end

def make_additional_information
  @requirements_templates.each do |requirement_template|
    AdditionalInformation.where(requirements_template_id: requirement_template.id,
                                url: 'http://additionalinfo1.com',
                                label: 'Additional Info Sample Label 1').first_or_create!

    AdditionalInformation.where(requirements_template_id: requirement_template.id,
                                url: 'http://additionalinfo2.com',
                                label: 'Additional Info Sample Label 2').first_or_create!
  end
end

def make_sample_plans
  @requirements_templates.each do |requirement_template|
    SamplePlan.where(requirements_template_id: requirement_template.id,
                     url: 'http://sampleplan1.com',
                     label: 'Sample Plan 1').first_or_create!

    SamplePlan.where(requirements_template_id: requirement_template.id,
                     url: 'http://sampleplan2.com',
                     label: 'Sample Plan 2').first_or_create!
  end
end

def make_resource_templates
  @requirements_templates.each do |requirement_template|
    ResourceTemplate.where(institution_id: requirement_template.institution.id,
                           requirements_template_id: requirement_template.id,
                           name: "Sample Resource Template for #{requirement_template.name} (Active/Mandatory)",
                           active: true,
                           mandatory_review: true,
                           widget_url: 'http://widgeturl.com').first_or_create!

    ResourceTemplate.where(institution_id: requirement_template.institution.id,
                           requirements_template_id: requirement_template.id,
                           name: "Sample Resource Template for #{requirement_template.name} (Inactive/Mandatory)",
                           active: false,
                           mandatory_review: true,
                           widget_url: 'http://widgeturl.com').first_or_create!

    ResourceTemplate.where(institution_id: requirement_template.institution.id,
                           requirements_template_id: requirement_template.id,
                           name: "Sample Resource Template for #{requirement_template.name} (Active/Not Mandatory)",
                           active: true,
                           mandatory_review: false,
                           widget_url: 'http://widgeturl.com').first_or_create!

    ResourceTemplate.where(institution_id: requirement_template.institution.id,
                           requirements_template_id: requirement_template.id,
                           name: "Sample Resource Template for #{requirement_template.name} (Inactive/Not Mandatory)",
                           active: false,
                           mandatory_review: false,
                           widget_url: 'http://widgeturl.com').first_or_create!
  end
end


def make_resources
  RequirementsTemplate.includes(:resource_templates, :requirements).each do |requirement_template|
    requirement_template.resource_templates.each do |resource_template|
      Resource.where(resource_type: :actionable_url,
                     value: "http://actionableurl#{resource_template.name}.com",
                     label: "#{resource_template.name} Actionable URL",
                     requirement_id: requirement_template.requirements.first.id,
                     resource_template_id: resource_template.id).first_or_create!

      Resource.where(resource_type: :expository_guidance,
                     value: "This is some guidance.",
                     label: "#{resource_template.name} Guidance",
                     requirement_id: requirement_template.requirements.first.id,
                     resource_template_id: resource_template.id).first_or_create!

      Resource.where(resource_type: :example_response,
                     value: "This is an example response.",
                     label: "#{resource_template.name} Example Response",
                     requirement_id: requirement_template.requirements.first.id,
                     resource_template_id: resource_template.id).first_or_create!

      Resource.where(resource_type: :suggested_response,
                     value: "This is an suggested response.",
                     label: "#{resource_template.name} Suggested Response",
                     requirement_id: requirement_template.requirements.first.id,
                     resource_template_id: resource_template.id).first_or_create!
    end
  end

end
