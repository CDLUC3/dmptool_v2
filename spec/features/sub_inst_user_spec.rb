require 'spec_helper'
require 'support/features/credentials'
include Credentials

feature 'sub institution user scope' do

  scenario 'parent template visible for sub institution user' do #, js: true do
    logs_in_with "#{CDL_USERNAME}", "#{CDL_PASSWORD}", "#{CDL_INSTITUTION_NAME}"
    find(:xpath, "//a[text()='Create New DMP'][@href='/plan_template_information']").click
    expect(page).to have_content 'To create a new DMP, select a funder or institutional template.'
    click_on('Select Template >>')
    click_on('UCOP')
    expect(page).to have_text('ucop_institutional_template_informal_review')
  end


  scenario 'sub-institution template visible for sub institution user' do #, js: true do
    logs_in_with "#{CDL_USERNAME}", "#{CDL_PASSWORD}", "#{CDL_INSTITUTION_NAME}"
    find(:xpath, "//a[text()='Create New DMP'][@href='/plan_template_information']").click
    expect(page).to have_content 'To create a new DMP, select a funder or institutional template.'
    click_on('Select Template >>')
    click_on('UCOP')
    expect(page).to have_text('cdl_institutional_template_with_optional_review')
  end

  
  scenario 'sub institution user can copy parent institutional plan', js: true do
    logs_in_with "#{CDL_USERNAME}", "#{CDL_PASSWORD}", "#{CDL_INSTITUTION_NAME}"
    visit(plan_template_information_path)
    click_on('Select Template >>')
    click_on('UCOP')
    page.choose 'ucop_institutional_template_informal_review'
    click_on 'Next'
    choose 'institutional'
    fill_in 'DMP Title', with: "temp_ucop_institutional_plan"
    click_on 'Save and Next'

    expect(page).to have_text('Plan was successfully created')

    visit(plan_template_information_path)
  
    if page.has_link?('Last »')
       click_on 'Last »'
      end
    
    expect(page).to have_text('temp_ucop_institutional_plan')

    
    within('#quick_dashboard') do
      click_link 'My DMPs'
    end
    find('#temp_ucop_institutional_plan').hover
    find('.delete').click
    find('.confirm').click

    expect(page).to have_text('The plan has been successfully deleted.')
  end


  scenario 'sub institution user cannot copy sibling unit plan and doesnt see it in public dmps page', js: true do
    logs_in_with "#{NRS_USERNAME}", "#{NRS_PASSWORD}", "#{NRS_INSTITUTION_NAME}"
    visit(plan_template_information_path)
    click_on('Select Template >>')
    click_on('UCOP')
    page.choose 'NRS_institutional_template_no_review'
    click_on 'Next'
    choose 'unit'
    fill_in 'DMP Title', with: "temp_nrs_unit_plan"
    click_on 'Save and Next'

    expect(page).to have_text('Plan was successfully created')

    visit(plan_template_information_path)
    
    if page.has_link?('Last »')
      click_on 'Last »'
    end
    
    expect(page).to have_text('temp_nrs_unit_plan')

    logs_out
    logs_in_with "#{CDL_USERNAME}", "#{CDL_PASSWORD}", "#{CDL_INSTITUTION_NAME}"
    visit(plan_template_information_path)
    
    if page.has_link?('Last »')
      click_on 'Last »'
    end  

    expect(page).to have_no_text('temp_nrs_unit_plan')

    click_on 'Public DMPs'
    visit '/public_dmps?institutional%3Aall_scope=all'

    expect(page).to have_no_text('temp_nrs_unit_plan')

    logs_out
    logs_in_with "#{NRS_USERNAME}", "#{NRS_PASSWORD}", "#{NRS_INSTITUTION_NAME}"
    within('#quick_dashboard') do
      click_link 'My DMPs'
    end
    find('#temp_nrs_unit_plan').hover
    find('.delete').click
    find('.confirm').click

    expect(page).to have_text('The plan has been successfully deleted.')
  end


  scenario 'sub institution user can copy and has access in public dmp page sibling institutional plan', js: true do
    logs_in_with "#{NRS_USERNAME}", "#{NRS_PASSWORD}", "#{NRS_INSTITUTION_NAME}"
    visit(plan_template_information_path)
    click_on('Select Template >>')
    click_on('UCOP')
    page.choose 'NRS_institutional_template_no_review'
    click_on 'Next'
    choose 'institutional'
    fill_in 'DMP Title', with: "temp_nrs_institutional_plan"
    click_on 'Save and Next'

    expect(page).to have_text('Plan was successfully created')

    logs_out
    logs_in_with "#{CDL_USERNAME}", "#{CDL_PASSWORD}", "#{CDL_INSTITUTION_NAME}"
    visit(plan_template_information_path)
 
    if page.has_link?('Last »') 
     click_on 'Last »'
    end

    expect(page).to have_text('temp_nrs_institutional_plan')

    click_on 'Public DMPs'
    visit '/public_dmps?institutional%3Aall_scope=all'

    expect(page).to have_text('temp_nrs_institutional_plan')

    logs_out
    logs_in_with "#{NRS_USERNAME}", "#{NRS_PASSWORD}", "#{NRS_INSTITUTION_NAME}"
    within('#quick_dashboard') do
      click_link 'My DMPs'
    end
    find('#temp_nrs_institutional_plan').hover
    find('.delete').click
    find('.confirm').click

    expect(page).to have_text('The plan has been successfully deleted.')
  end

  
end



