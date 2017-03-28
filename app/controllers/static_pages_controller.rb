require 'rss'

class StaticPagesController < ApplicationController

  layout 'application', only: [:guidance, :contact]

  def orcid
    respond_to :html
    render(layout: nil)
  end

  def home
    respond_to :html
    @rss = Rails.cache.read('rss')
    @public_dmps = Plan.public_visibility.order(name: :asc).limit(3)
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
    respond_to :html
  end

  def video
    respond_to :html
  end

  def partners
    respond_to :html
  end

  def help
    respond_to :html
  end

  def contact
    respond_to :html
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
        all_emails = APP_CONFIG['feedback_email_to'] + addl_to
        all_emails.delete_if {|x| x.blank? } #delete any blank emails
        all_emails.each do |i|
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
    respond_to :html
  end

  def guidance
    respond_to :html
    @public_templates = RequirementsTemplate.public_visibility.includes(:institution, :sample_plans, :additional_informations).active.current.public_visibility

    @scope1 = params[:scope1]
    @order_scope1 = params[:order_scope1]
    @s = params[:s]
    @e = params[:e]

    case @order_scope1
      when "Template"
        @public_templates = @public_templates.order(name: :asc)
      when "Institution"
        @public_templates = @public_templates.order('institutions.full_name ASC')
      when "InstitutionLink"
        @public_templates = @public_templates.order('additional_informations.label ASC')
      when "SamplePlans"
        @public_templates = @public_templates.order('sample_plans.label ASC')
      else
        @public_templates = @public_templates.order(name: :asc)
    end

    case @scope1
      when "all"
        @public_templates = @public_templates.page(params[:public_guidance_page]).per(1000)
      else
        @public_templates = @public_templates.page(params[:public_guidance_page]).per(10)
    end

    unless params[:s].blank? || params[:e].blank?
      @public_templates = @public_templates.letter_range_by_institution(params[:s], params[:e])
    end

    if !params[:q].blank?
      @public_templates = @public_templates.search_terms(params[:q])
    end

    if current_user

      @scope2 = params[:scope2]
      @order_scope2 = params[:order_scope2]

      @institution_templates = current_user.institution.requirements_templates_deep.institutional_visibility.active.current.
              includes(:institution, :sample_plans, :additional_informations)


      case @order_scope2
        when "Template"
          @institution_templates = @institution_templates.order(name: :asc)
        when "Institution"
          @institution_templates = @institution_templates.order('institutions.full_name ASC')
        when "InstitutionLink"
          @institution_templates = @institution_templates.order('additional_informations.label ASC')
        when "SamplePlans"
          @institution_templates = @institution_templates.order('sample_plans.label ASC')
        else
          @institution_templates = @institution_templates.order(name: :asc)
      end

      case @scope2
        when "all"
          @institution_templates = @institution_templates.page(params[:institutional_guidance_page]).per(1000)
        else
          @institution_templates = @institution_templates.page(params[:institutional_guidance_page]).per(10)
      end

    end

  end
end
