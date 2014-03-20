require 'spec_helper'

describe PlanStatesController do

  describe "GET 'accept'" do
    it "returns http success" do
      get 'accept'
      response.should be_success
    end
  end

  describe "GET 'reject'" do
    it "returns http success" do
      get 'reject'
      response.should be_success
    end
  end

  describe "GET 'submit'" do
    it "returns http success" do
      get 'submit'
      response.should be_success
    end
  end

  describe "GET 'committed'" do
    it "returns http success" do
      get 'committed'
      response.should be_success
    end
  end

  describe "GET 'finish'" do
    it "returns http success" do
      get 'finish'
      response.should be_success
    end
  end

end
