require 'rss'

class StaticPagesController < ApplicationController
  
  layout 'application', only: [:guidance]
  
  def home
    @rss = Rails.cache.read('rss')
    @public_dmps = Plan.public_visibility.order("RAND()")[0..4]
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
  
  def video
  end
  
  def partners
  end

  def help
  end

  def contact
    if request.post?
      if verify_recaptcha
        msg = []
        msg.push('Please indicate what your question is about') if params[:question_about].blank?
        msg.push('Please enter your name') if params[:name].blank?
        msg.push('Please enter your email') if params[:email].blank?
        msg.push('Please enter a message') if params[:message].blank?
        if !params[:email].blank? && !params[:email].match(/^\S+@\S+$/)
          msg.push('Please enter a valid email address')
        end
        if msg.length > 0
          flash[:error] = msg
          redirect_to contact_path(question_about: params['question_about'], name: params['name'],
                                   email: params['email'], message: params[:message]) and return
        end

        addl_to = (current_user ? [current_user.institution.contact_email] : [])
        (APP_CONFIG['feedback_email_to'] + addl_to).each do |i|
          GenericMailer.contact_email(params, i).deliver
        end
        flash[:alert] = "Your email message was sent to the DMPTool team."
        redirect_to :back and return
      end
      redirect_to contact_path(question_about: params['question_about'], name: params['name'],
                          email: params['email'], message: params[:message]) and return
    end
  end
  
  def privacy
  end
  
  def guidance
    @public_templates = RequirementsTemplate.public_visibility.includes(:institution, :sample_plans)
    
    unless params[:s].blank? || params[:e].blank?
      @public_templates = @public_templates.letter_range_by_institution(params[:s], params[:e])
    end
    
    if !params[:q].blank?
      @public_templates = @public_templates.search_terms(params[:q])
    end
    page_size = (params[:all_records_public] == 'true'? 999999 : 10)
    @public_templates = @public_templates.page(params[:public_page]).per(page_size)
    
    if current_user
      inst = current_user.institution
      page_size = (params[:all_records_institution] == 'true'? 999999 : 10)
      @institution_templates = inst.requirements_templates_deep.institutional_visibility.
              includes(:institution, :sample_plans).page(params[:institution_page]).per(page_size)
    end
  end
end
