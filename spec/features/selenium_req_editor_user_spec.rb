require "selenium-webdriver"
require "rspec-expectations"
require 'spec_helper'
include  Credentials



describe "SeleniumReqEditorUserSpec" do

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
  
  it "test_req_editor_user_spec" do

    #requirement editor logs in with Smithsonian Institution
    @driver.get(@base_url)
    @driver.find_element(:link, "Log In").click
    @driver.find_element(:tag_name, "select").find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_ID}']").click
    @driver.find_element(:name, "commit").click
    @driver.find_element(:id, "username").send_keys REQ_EDITOR_USERNAME  
    @driver.find_element(:id, "password").send_keys REQ_EDITOR_PASSWORD
    @driver.find_element(:name, "commit").click
    assert_equal "Welcome! #{REQ_EDITOR_FIRST_NAME}", @driver.find_element(:css, "p").text

    #he has requirement editor visibility quick-dashboard
    @driver.find_element(:link, "My Dashboard").text
    @driver.find_element(:link, 'My DMPs').text
    @driver.find_element(:link, 'Create New DMP').text
    @driver.find_element(:link, 'My Profile').text
    @driver.find_element(:link, 'DMP Templates').text

    @driver.find_element(:css, "a").text.should_not == 'Resources'
    @driver.find_element(:css, "a").text.should_not == 'Institution Profile' 
    @driver.find_element(:css, "a").text.should_not == 'DMP Administration'  

    #he changes his institution in the My Profile page (from SI to Museum of Natural History)
    @driver.find_element(:link, "My Profile").click
    #assert_equal "Smithsonian Institution", @driver.find_element(:css, "option[value='6']").text  
    @driver.find_element(tag_name: 'select').find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_ID}']").selected?.should == true  
    @driver.find_element(:name, "user[institution_id]").find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_CHILD_ID}']").click
    @driver.find_element(tag_name: 'select').find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_CHILD_ID}']").selected?.should == true 
    @driver.find_element(:name, "user[institution_id]").find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_ID}']").click
    @driver.find_element(tag_name: 'select').find_element(:css,"option[value='#{REQ_EDITOR_INSTITUTION_ID}']").selected?.should == true 

    #creates a new DMP template
    @driver.find_element(:link, "DMP Templates").click
    @driver.find_element(:xpath, "//input[@value='Create New template']").click
    @driver.find_element(:xpath, "(//input[@value='Template Information'])[2]").click


    

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