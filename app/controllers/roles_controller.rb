class Roles < ApplicationController


  # GET /roles/new
  def new
    @role = Role.new(:role_id => params[:role_id])
  end

  # def add_role
  #     emails = params[:email].split(/,\s*/) unless params[:email] == ""
  #     role  = Role.where(name: 'resources_editor').first
  #     @invalid_emails = []
  #     @existing_emails = []
  #     emails.each do |email|
  #       @user = User.find_by(email: email)
  #       if @user.nil?
  #         @invalid_emails << email
  #       else
  #         begin
  #           @user.roles << role
  #           authorization = Authorization.where(user_id: @user.id, role_id: role.id).pluck(:id).first
  #           institution = @user.institution.id
  #           pg = PermissionGroup.create(authorization_id: authorization, institution_id: institution)
  #           pg.save!
  #         rescue ActiveRecord::RecordNotUnique
  #           @existing_emails << email
  #         end
  #       end
  #     end
  #     respond_to do |format|
  #       if (!@invalid_emails.empty? && !@existing_emails.empty?)
  #         flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified and Users with #{@existing_emails.join(', ')} already have been assigned the Resouces Editor role. "
  #         format.js { render action: 'add_role' }
  #       elsif (!@existing_emails.empty? && @invalid_emails.empty?)
  #         flash.now[:notice] = "The following emails #{@existing_emails.join(', ')} have already been assigned with this Resouces Editor role"
  #         format.js { render action: 'add_role' }
  #       elsif (@existing_emails.empty? && !@invalid_emails.empty?)
  #         flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified. "
  #         format.js { render action: 'add_role' }
  #       else
  #         flash.now[:notice] = "Added Resources Editor Role to the Users specified."
  #         format.js { render action: 'add_role' }
  #       end
  #     end
  #   end
  # end

end