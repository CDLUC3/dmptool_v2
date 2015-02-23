require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'ucop user scope' do

  scenario 'public dmp page visibility' do #, js: true do

    logs_in_with "#{UCOP_USERNAME}", "#{UCOP_PASSWORD}", "#{UCOP_INSTITUTION_NAME}"
    visit(public_dmps_path)
    
    expect(page).to have_content 'Institutional DMPs'
    expect(page).to have_content 'ucop_unit_plan'
    expect(page).to have_content 'cdl_unit_plan'
    expect(page).to have_content 'nrs_unit_plan'
    expect(page).to have_content 'ucop_institutional_plan'
    expect(page).to have_content 'ucop_institutional_plan'
    expect(page).to have_content 'ucop_institutional_plan'

  end


  # scenario 'public dmp shown from institutional parent', js: true do

  #   logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"
  #   visit(public_dmps_path)
  #   #find(:css, 'a#institutional_view_all_plans').click
  #   expect(page).to have_text('top_level_plan_my_dog_has_fleas')

  # end


  # scenario 'copy template from institutional parent', js: true do

  #   logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"
  #   visit(requirements_templates_path)
  #   click_on('Create New Template >>')
  #   expect(page).to have_text('Create New DMP Template')

  #   #click_link('4')
  #   find(:css, 'input#requirements_template_47').click

  #   click_on('Copy Template')

  #   expect(page).to have_text('Requirements template was successfully created.')

  #   click_on('Save and Next >>')

  #   expect(page).to have_text('etaoin shrdlu')

  #   click_on('Delete')

  #   find(:css, "div.modal-footer>a.confirm").click

  #   expect(page).to have_text('DMP template was deleted.')

  # end

  # scenario 'copy template from public template' , js: true do

  #   logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"
  #   visit(requirements_templates_path)
  #   click_on('Create New Template >>')
  #   expect(page).to have_text('Create New DMP Template')

  #   find(:css, 'input#requirements_template_2').click

  #   click_on('Copy Template')

  #   expect(page).to have_text('Requirements template was successfully created.')

  #   click_on('Save and Next >>')

  #   expect(page).to have_text('Policies for re-use, redistribution')

  #   click_on('Delete')

  #   find(:css, "div.modal-footer>a.confirm").click

  #   expect(page).to have_text('DMP template was deleted.')

  # end


end






