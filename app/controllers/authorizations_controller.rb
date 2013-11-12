class AuthorizationsController < ApplicationController


	
	def add_authorization

    emails = params[:email].split(/,\s*/) unless params[:email] == ""
    @role_id = params[:role_id]
    @role_name = params[:role_name]
    #@role_name = Role.where(id: @role_id).pluck(:name)
    @invalid_emails = []
    @existing_emails = []
    emails.each do |email|
      @user = User.find_by(email: email)
      if @user.nil?
        @invalid_emails << email
      else
        begin
          authorization = Authorization.create(role_id: @role_id, user_id: @user.id)
          authorization.save!
        rescue ActiveRecord::RecordNotUnique
          @existing_emails << email
        end
      end
    end
    respond_to do |format|
      if (!@invalid_emails.empty? && !@existing_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified and Users with #{@existing_emails.join(', ')} already have been assigned this role. "
        format.js { render action: 'add_authorization' }
      elsif (!@existing_emails.empty? && @invalid_emails.empty?)
        flash.now[:notice] = "The following emails #{@existing_emails.join(', ')} have already been assigned with this role"
        format.js { render action: 'add_authorization' }
      elsif (@existing_emails.empty? && !@invalid_emails.empty?)
        flash.now[:notice] = "Could not find Users with the following emails #{@invalid_emails.join(', ')} specified. "
        format.js { render action: 'add_authorization' }
      else
        flash.now[:notice] = "Granted #{@role_name} Role to the Users specified."
        format.js { render action: 'add_authorization' }
      end
    end
  end

end
