class StaticPagesController < ApplicationController
  
  layout 'application', only: [:guidance]
  
  def home
  end

  def about
  end

  def help
  end

  def contact
  end
  
  def guidance
  end
end
