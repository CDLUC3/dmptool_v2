require "selenium-webdriver"
require "rspec-expectations"
require 'spec_helper'
include  Credentials
include Module::Credentials


describe "SeleniumGenericUserSpec" do

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
  
  it "test_generic_user_spec" do

    #generic user with no specific roles logs in with Test Institution
    @driver.get(@base_url)
    @driver.find_element(:link, "Log In").click
    @driver.find_element(:tag_name, "select").find_element(:css,"option[value='1']").click
    @driver.find_element(:name, "commit").click
    @driver.find_element(:id, "username").send_keys GENERIC_USERNAME  
    @driver.find_element(:id, "password").send_keys GENERIC_PASSWORD
    @driver.find_element(:name, "commit").click
    assert_equal "Welcome! test_user2", @driver.find_element(:css, "p").text

    #he has the generic visibility quick-dashboard
    @driver.find_element(:link, "My Dashboard").text
    @driver.find_element(:link, 'My DMPs').text
    @driver.find_element(:link, 'Create New DMP').text
    @driver.find_element(:link, 'My Profile').text

    @driver.find_element(:css, "a").text.should_not == 'DMP Templates'
    @driver.find_element(:css, "a").text.should_not == 'Resources'
    @driver.find_element(:css, "a").text.should_not == 'Institution Profile' 
    @driver.find_element(:css, "a").text.should_not == 'DMP Administration'  

    #he changes his institution in the My Profile page
    @driver.find_element(:link, "My Profile").click
    assert_equal "Test Institution", @driver.find_element(:css, "option[value='1']").text   
    @driver.find_element(:name, "user[institution_id]").find_element(:css,"option[value='30']").click
    @driver.find_element(tag_name: 'select').find_element(:css,"option[value='30']").selected?.should == true 
    @driver.find_element(:name, "user[institution_id]").find_element(:css,"option[value='1']").click
    @driver.find_element(tag_name: 'select').find_element(:css,"option[value='1']").selected?.should == true 

    

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
