class Ability
  include CanCan::Ability
  ################ TO BE COMPLETED

  #   def initialize(user)

  #   user ||= User.new #guest user not logged in
  #   alias_action :create, :read, :update, :destroy, :to => :crud

  #   if user.has_role? :dmp_administrator
  #       can :manage, :all
  #   elsif user.has_role? :dmp_owner
  #       can :crud, Comment do |comment|
  #         comment.try(:user) == user && comment.type == 'owner'
  #       end
  #       can :crud, Plan do |plan|
  #         plan.try(:user) == user
  #       end
  #   elsif user.has_role? :dmp_coowner
  #       can [:read, :create], Comment do |comment|
  #         comment.try(:user) == user && comment.type == 'owner'
  #       end
  #       can :read, Plan do |plan|
  #         plan.try(:user) == user
  #       end
  #   elsif user.has_role? :requirements_editor
  #       can :crud, [RequirementsTemplate, Requirements]
  #   elsif user.has_role? :resources_editor
  #       can :crud, [ResourceTemplate, Resource]
  #   elsif user.has_role? :institutional_reviewer
  #       can :read, [ResourceTemplate, Resource]
  #       can [:read, :create], Comment do |comment|
  #         comment.try(user) == user && comment.type == 'reviewer'
  #       end
  #   else user.has_role? :institutional_administrator
  #       can :crud, [RequirementsTemplate, Requirements]
  #   end
end
