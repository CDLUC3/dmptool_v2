class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user, :safe_has_role?

  protected

  	def current_user
    	@current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
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

    def select_requirements_template
      req_temp = RequirementsTemplate.includes(:institution)
      valid_buckets = nil
      if current_user.has_role?(Role::DMP_ADMIN)
        #all records
      elsif current_user.has_role?(Role::TEMPLATE_EDITOR) || current_user.has_role?(Role::INSTITUTIONAL_ADMIN)
        req_temp = req_temp.where(institution_id: current_user.institution.subtree_ids)
        valid_buckets = current_user.institution.child_ids
        base_inst = current_user.institution.id
        valid_buckets = [ current_user.institution.id ] if valid_buckets.length < 1
      else
        @rt_tree = {}
        return
      end
      if !params[:q].blank?
        req_temp = req_temp.name_search_terms(params[:q])
      end
      if !params[:s].blank? && params[:e].blank?
        req_temp = req_temp.letter_range_by_institution(params[:s], params[:e])
      end

      rt_tree = {}
      #this creates a hash with institutions as keys and requirements_templates as values like below
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <institution_object2> => [<requirements_template_1>] }
      # This works slightly different between institutional admins and WAS admins since the tree
      # is not the same.
      req_temp.each do |rt|
        unless rt.institution.nil?
          if valid_buckets.nil?
            root_inst = rt.institution.root
          else
            inst_id = valid_buckets & rt.institution.path_ids
            inst_id = [ base_inst ] if inst_id.empty?
            root_inst = Institution.find(inst_id.first)
          end
          if rt_tree.has_key?(root_inst)
            rt_tree[root_inst].push(rt)
          else
            rt_tree[root_inst] = [ rt ]
          end
        end
      end

      #this transforms the hash so that there is a possible 2-level heirarchy like institution => [req_template1, req_template2] or
      # req_template => nil, see example below:
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <requirements_template_1> => nil }
      @rt_tree = {}
      rt_tree.each do |k,v|
        if v.length > 1
          @rt_tree[k] = v
        else
          v.each do |i|
            @rt_tree[i] = nil
          end
        end
      end

      # sort out for institutional admins so that their institution templates appear on first level if any
      if !valid_buckets.nil? && @rt_tree.has_key?(current_user.institution)
        templates = @rt_tree.delete(current_user.institution)
        templates.each do |t|
          @rt_tree[t] = nil
        end
      end

      #sort first level items by name (both institutions and requirements templates)
      @rt_tree = Hash[@rt_tree.sort{|x,y| x[0].name.downcase <=> y[0].name.downcase}]

      #sort any second level items by name (just requirements templates within an institution)
      @rt_tree.each do |k, v|
        v.sort!{|x, y| x.name.downcase <=> y.name.downcase} unless v.nil?
      end

      #put all results at top level if only one institution has results
      if @rt_tree.length == 1 && !@rt_tree.first[1].nil?
        temp = {}
        @rt_tree.first[1].each do |i|
          temp[i] = nil
        end
        @rt_tree = temp
      end
    end
end
