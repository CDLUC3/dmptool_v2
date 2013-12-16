require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'dmp admin user' do

    scenario 'scenarios' do

        logs_in_with "#{DMP_ADMIN_USERNAME}", "#{DMP_ADMIN_PASSWORD}", "#{DMP_ADMIN_INSTITUTION_NAME}"

        expect(page).to have_link('My Dashboard')
        expect(page).to have_link('My Profile')
        expect(page).to have_link('DMP Templates')
        expect(page).to have_link('Resources')
        expect(page).to have_link('Institution Profile')
        expect(page).to have_link('DMP Administration')

    #MY DASHBOARD TEST

    #My Dashboard sections are present
    click_link 'My Dashboard'
    expect(page).to have_content("Overview")
    expect(page).to have_content("DMPs For My Review")
    expect(page).to have_content("DMP Templates")
    expect(page).to have_content("Resource Templates")

    #buttons are functioning (create new dmp is not working)
    click_on "create_new_DMP_template"
    click_link "My Dashboard"
    click_on "create_new_resource_template"
    expect(page).to have_content("Resource Template Overview")

    #links are functioning
    click_link 'My Dashboard'
    click_on "institutional_templates" #DMP Templates for my institution only
    expect(page).to have_content("Visibility")
    expect(page).to have_content("Institutional")

    click_link 'My Dashboard'
    click_on "public_templates" #Public DMP Templates
    expect(page).to have_content("Visibility")
    expect(page).to have_content("Public")

    click_link 'My Dashboard'
    click_on "resources_templates" # Resources Templates
    expect(page).to have_content("Resource Editors")

    end


end

