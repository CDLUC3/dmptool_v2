require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'sub institution user scope' do

  scenario 'template availability shown for institutional parent', js: true do

    logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"
    # click the Create New DMP link with the path below, otherwise there are duplicates
    find(:xpath, "//a[text()='Create New DMP'][@href='/plan_template_information']").click
    expect(page).to have_content 'To create a new DMP, select a funder or institutional template.'
    click_on('Select Template >>')
    expect(page).to have_field('requirements_template_id_46')
    expect(page).to have_text('top_level_test_inst_template')

  end

  scenario 'public dmp shown from institutional parent', js: true do

    logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"
    visit(public_dmps_path)
    click_on('View All')
    expect(page).to have_text('top_level_plan_my_dog_has_fleas')

  end



end