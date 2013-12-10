require "selenium-webdriver"
require "rspec-expectations"
require 'spec_helper'
include  Credentials



describe "SeleniumDmpAdminUserSpec" do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://localhost:3000/logout"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  
  it "selenium_dmp_admin_user_spec" do

    #dmp admin logs in 
    @driver.get(@base_url)
    @driver.find_element(:link, "Log In").click
    @driver.find_element(:tag_name, "select").find_element(:css,"option[value='#{DMP_ADMIN_INSTITUTION_ID}']").click
    @driver.find_element(:name, "commit").click
    @driver.find_element(:id, "username").send_keys DMP_ADMIN_USERNAME  
    @driver.find_element(:id, "password").send_keys DMP_ADMIN_PASSWORD
    @driver.find_element(:name, "commit").click

    #DMP admin visibility quick-dashboard
    @driver.find_element(:link, "My Dashboard").text
    @driver.find_element(:link, 'My DMPs').text
    @driver.find_element(:link, 'Create New DMP').text
    @driver.find_element(:link, 'My Profile').text
    @driver.find_element(:link, 'DMP Templates').text
    @driver.find_element(:link, 'Resources').text
    @driver.find_element(:link, 'Institution Profile').text
    @driver.find_element(:link, 'DMP Administration').text 

    #My Dashboard sections are present
    @driver.find_element(:link, "My Dashboard").click
    @driver.find_element(:css, "h3.dashboard-heading").text.should == "OVERVIEW"
    @driver.find_elements(:css, "h3.dashboard-heading").include?("DMPs For My Review")
    @driver.find_elements(:css, "h3.dashboard-heading").include?("DMP Templates")
    @driver.find_elements(:css, "h3.dashboard-heading").include?("Resource Templates")
    
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end