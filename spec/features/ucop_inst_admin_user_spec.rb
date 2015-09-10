require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'ucop institutional admin user scope' do

  # scenario 'ucop admin grants and revokes roles to ucop user', js: true do

  #   logs_in_with "#{UCOP_INST_ADMIN_USERNAME}", "#{UCOP_INST_ADMIN_PASSWORD}", "#{UCOP_INST_ADMIN_INSTITUTION_NAME}"
    
  #   click_link 'Institution Profile'
  #   click_link 'Assign Roles'

  #   #ucop admin grants role

  #   fill_in 'template_editor_name', with: 'ucopuser001'
  #   # save_and_open_page
  #   select 'ucopuser001 ucopuser001 <ucopuser001@gmail.com>'
  #   within '#4' do
  #       check 'role_ids[]'
  #   end 
  #   click_button "Grant Role"

  #   expect(page).to have_content 'ucopuser 001 has been updated'

  #   within '#user_7' do
  #       expect(page).to have_content '001 ucopuser'
  #   end 
    
  #   #ucop admin revokes role

  #   click_link edit_7
  #   within '#4' do
  #       uncheck 'role_ids[]'
  #   end
  #   click_button "Save Changes"

  #   expect(page).to have_content 'User was successfully updated.'
  #   expect(page).to have_no_content('001 ucopuser')

  # end


  # scenario 'ucop admin grants and revokes roles to cdl user' do #, js: true do

  #   logs_in_with "#{UCOP_INST_ADMIN_USERNAME}", "#{UCOP_INST_ADMIN_PASSWORD}", "#{UCOP_INST_ADMIN_INSTITUTION_NAME}"
    
  #   click_link 'Institution Profile'
  #   click_link 'Assign Roles'

  #   #ucop admin grants role

  #   fill_in 'template_editor_name', with: 'ucopuser001'
  #   click_link 'cdluser 001 <cdluser001@gmail.com>'
  #   within '#4' do
  #       check 'role_ids[]'
  #   end 
  #   click_button "Grant Role"

  #   expect(page).to have_content 'cdluser 001 has been updated'

  #   within '#user_8' do
  #       expect(page).to have_content '001 cdluser'
  #   end 
    
  #   #ucop admin revokes role

  #   click_link edit_7
  #   within '#4' do
  #       uncheck 'role_ids[]'
  #   end
  #   click_button "Save Changes"

  #   expect(page).to have_content 'User was successfully updated.'
  #   expect(page).to have_no_content('001 cdluser')

  # end

end