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
    @public_templates = RequirementsTemplate.public_visibility.includes(:institution, :sample_plans)
    
    if params[:s] && params[:e]
      @public_templates = @public_templates.letter_range(params[:s], params[:e])
    end
    
    if current_user
      inst = current_user.institution
      @institution_templates = inst.requirements_templates_deep.#institutional_visibility.
              includes(:institution, :sample_plans)
    end
  end
end
