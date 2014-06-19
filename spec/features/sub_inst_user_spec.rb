require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'sub user scope' do

  scenario 'sub user resource visibility', js: true do

    logs_in_with "#{SUB_USER_USERNAME}", "#{SUB_USER_PASSWORD}", "#{SUB_USER_INSTITUTION_NAME}"

    # click the Create New DMP link with the path below, otherwise there are duplicates
    find(:xpath, "//a[text()='Create New DMP'][@href='/plan_template_information']").click

    expect(page).to have_content 'To create a new DMP, select a funder or institutional template.'

    click_on('Select Template >>')

    sleep 5

  end

end