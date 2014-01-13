require 'rss'

class StaticPagesController < ApplicationController
  
  layout 'application', only: [:guidance]
  
  def home
    @rss = Rails.cache.read('rss')
    if @rss.nil?
      begin
        rss_xml = open(APP_CONFIG['rss']).read
        @rss = RSS::Parser.parse(rss_xml, false).items.first(5)
        Rails.cache.write("rss", @rss, :expires_in => 15.minutes)
      rescue Exception => e
        logger.error("Caught exception: #{e}.")
      end
    end
  end

  def about
  end

  def help
  end

  def contact
    if request.post?
      flash[:alert] = "this is a post request where the form is submitted and en email may be sent."
      redirect_to :back
    end
  end
  
  def guidance
    @public_templates = RequirementsTemplate.public_visibility.includes(:institution, :sample_plans)
    
    if params[:s] && params[:e]
      @public_templates = @public_templates.letter_range_by_institution(params[:s], params[:e])
    end
    
    if params[:q]
      @public_templates = @public_templates.search_terms(params[:q])
    end
    
    if current_user
      inst = current_user.institution
      @institution_templates = inst.requirements_templates_deep.#institutional_visibility.
              includes(:institution, :sample_plans)
    end
  end
end
