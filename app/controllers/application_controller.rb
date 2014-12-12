class ApplicationController < ActionController::Base

  ROLES =
      {	  :dmp_admin              => Role::DMP_ADMIN,
          :resource_editor        => Role::RESOURCE_EDITOR,
          :template_editor        => Role::TEMPLATE_EDITOR,
          :institutional_reviewer => Role::INSTITUTIONAL_REVIEWER,
          :institutional_admin    => Role::INSTITUTIONAL_ADMIN}


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # enable_authorization

  helper_method :current_user, :safe_has_role?, :require_login, :user_role_in?

  protected

  	def current_user
    	@current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def require_login
      if session[:user_id].blank?
        flash[:error] = "You must be logged in to access this page."
        session[:return_to] = request.original_url
        redirect_to choose_institution_path and return
      end
    end

    #require that a user is logged out
    def require_logout
      if session && !session[:user_id].blank?
        flash[:error] = "The page you're trying to access is only available to logged out users."
        redirect_to dashboard_path and return
      end
    end

    #checks you're an editor for customizations in general
    def check_customization_editor
      unless user_role_in?(:dmp_admin, :resource_editor, :institutional_admin)
        flash[:error] = "You do not have permission to view this page."
        redirect_to dashboard_path and return
      end
    end

    #checks the user is allowed to edit page in this customization context
    #in this case a customization must be a container for other customizations (#6 and #8)
    #and params[:id] is the number of the container customization.
    def check_editor_for_this_customization
      if params[:id].blank?
        flash[:error] = 'A customization id is missing'
        redirect_to resource_contexts_path and return 
      end
      cust = ResourceContext.find_by_id(params[:id])
      level = cust.resource_level unless cust.nil?
      if cust.nil? || !level['Container'] #this isn't a container customization
        flash[:error] = "You've selected an incorrect customization"
        redirect_to resource_contexts_path and return
      end
      # the user doesn't have permissions on this institution and isn't a DMP admin
      if !current_user.institution.subtree_ids.include?(cust.institution_id) && !user_role_in?(:dmp_admin)
        flash[:error] = "You do not have permission to view this page."
        redirect_to dashboard_path and return
      end
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

    # a shorter method to see if user has any of these roles and returns true if has any of the roles passed in.
    # pass in any of these
    # :dmp_admin, :resource_editor, :template_editor,  :institutional_reviewer, :institutional_admin
    def user_role_in?(*roles)
      if (roles - ROLES.keys).length > 0
        raise "role not defined in application_controller#user_role_in?.  It's likely you've mistyped a role symbol."
      end
      return false if current_user.nil?
      r = roles.map {|i| ROLES[i]}
      matching_roles = current_user.roles.pluck(:id) & r
      return true if matching_roles.length > 0
      return false
    end

    def check_admin_access
      unless user_role_in?(:dmp_admin, :resource_editor, :template_editor, :institutional_reviewer, :institutional_reviewer)
        if current_user
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_institution_admin_access
      unless user_role_in?(:dmp_admin, :institutional_admin)
        if current_user
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_dmp_admin_access
      unless user_role_in?(:dmp_admin)
        if current_user
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    

    def check_DMPTemplate_editor_access
      unless user_role_in?(:dmp_admin, :institutional_admin, :template_editor, :resource_editor)
        if current_user
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def view_DMP_index_permission
      unless user_role_in?(:dmp_admin, :institutional_admin, :template_editor, :resource_editor)
        if current_user
          flash[:error] = "You don't have access to this content."
        else
          flash[:error] = "You need to be logged in."
        end
        redirect_to root_url # halts request cycle
      end
    end

    def check_resource_editor_access
      unless user_role_in?(:dmp_admin, :institutional_admin, :resource_editor)
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

    def make_institution_dropdown_list
      @inst_list = InstitutionsController.institution_select_list
    end

    def process_requirements_template(requirement_templates)

      institutions = get_base_institution_buckets(requirement_templates)

      return {} if institutions.blank?

      #this creates a hash with institutions as keys and requirements_templates as values like below
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <institution_object2> => [<requirements_template_1>] }
      # This works slightly different between institutional admins and WAS admins since the tree
      # is not the same.
      rt_tree = Hash[institutions.map{|i| [i, requirement_templates.where(institution_id: i.subtree_ids)] }]

      #this transforms the hash so that there is a possible 2-level heirarchy like institution => [req_template1, req_template2] or
      # req_template => nil, see example below:
      # { <institution_object1> => [<requirements_template_1>, <requirements_template_2> ],
      #     <requirements_template_1> => nil }
      @rt_tree = Hash[rt_tree.map{|i| (i[1].length == 1 ? [i[1].first, nil] : i )} ]


      # sort out for institutional admins so that their institution templates appear on first level if any
      #if !valid_buckets.nil? && @rt_tree.has_key?(current_user.institution)
      #  templates = @rt_tree.delete(current_user.institution)
      #  templates.each do |t|
      #    @rt_tree[t] = nil
      #  end
      #end

      #sort first level items by name (both institutions and requirements templates)
      @rt_tree = Hash[@rt_tree.sort{|x,y| x[0].name.downcase <=> y[0].name.downcase}]

      #sort any second level items by name (just requirements templates within an institution)
      @rt_tree.each do |k, v|
        v.sort!{|x, y| x.name.downcase <=> y.name.downcase} unless v.nil?
      end

      #put all results at top level if only one institution has results
      if @rt_tree.length == 1 && !@rt_tree.first[1].nil?
        @rt_tree = Hash[ @rt_tree.first[1].map{|i| [i, nil]} ]
      end
    end

  private
    def get_base_institution_buckets(requirements_templates)
      insts = Institution.where(id: requirements_templates.pluck(:institution_id)).distinct
      least_depth = 1000
      insts.each do |i|
        least_depth = i.depth if i.depth < least_depth
        break if least_depth == 0
      end
      return {} if least_depth == 1000
      inst_ids = insts.map { |i|  (i.ancestor_ids + [ i.id])[least_depth] }

      Institution.find(inst_ids)
    end
  end
