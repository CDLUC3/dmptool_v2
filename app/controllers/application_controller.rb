class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user, :safe_has_role?

  protected

  	def current_user
    	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  	end
    
    def safe_has_role?(role)
      #this returns whether a user has a role, but does it safely.  If no user is logged in
      #then it returns false by default.  Will work with either number or more readable role name.
      return false if current_user.nil?
      if role.class == Fixnum || (role.class == String && role.match(/^[-+]?[1-9]([0-9]*)?$/) )
        current_user.has_role?(role)
      else
        current_user.has_role_name?(role)
      end
    end

    def check_admin_access
      unless (safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::RESOURCE_EDITOR) ||
            safe_has_role?(Role::TEMPLATE_EDITOR) ||
            safe_has_role?(Role::INSTITUTIONAL_REVIEWER) ||
            safe_has_role?(Role::INSTITUTIONAL_ADMIN))    
        if current_user   
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_institution_admin_access
      unless (safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::INSTITUTIONAL_ADMIN) ) 
        if current_user   
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_dmp_admin_access
      unless (safe_has_role?(Role::DMP_ADMIN) )    
        if current_user   
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_DMPTemplate_editor_access
      unless (safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::INSTITUTIONAL_ADMIN) ||
               safe_has_role?(Role::TEMPLATE_EDITOR) )    
        if current_user   
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_resource_editor_access
      unless (safe_has_role?(Role::DMP_ADMIN) || safe_has_role?(Role::INSTITUTIONAL_ADMIN) ||
               safe_has_role?(Role::RESOURCE_EDITOR) )    
        if current_user   
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end
    
    def sanitize_for_filename(filename)
      ActiveSupport::Inflector.transliterate filename.downcase.gsub(/[\\\/?:*"><|]+/,"_").gsub(/\s/,"_")
    end

end
