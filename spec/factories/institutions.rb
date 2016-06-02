FactoryGirl.define do
  
  factory :fg_institution, class: Institution do
    full_name "University of California - Test" 
    nickname "UCT"
    desc "This is the description."
    
    contact_info 'Contact for testing'
    contact_email 'dmptool-test@ucop.edu'
    
    url 'http://dmptool.org'
    url_text 'DMPTool - Testing'
    
    shib_entity_id 'DMPTOOL-TEST'
    shib_domain 'http://dmptool.org/shib/test'
  end
  
end