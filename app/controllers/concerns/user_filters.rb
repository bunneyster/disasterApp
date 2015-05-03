module UserFilters
  # (before-filter) ensures that the session belongs to a registered user
  def authenticated_as_user
    return bounce_user if current_user.nil?
    return true if current_user.email_credential.verified?
    # Inactive user.
    set_session_current_user nil
    bounce_user
  end

  # (before-filter) ensures that the session belongs to an administrator
  def authenticated_as_admin
    authenticated_as_user
    return if performed?

    bounce_user unless current_user.admin?
  end

  # (before-filter) ensures that the current user has chosen a role in the app
  def authenticated_as_user_with_role
    authenticated_as_user
    return if performed?
  end

  # (before-filter) ensures that the session belongs to a consumer
  def authenticated_as_consumer
    authenticated_as_user
    return if performed?

    redirect_to user_role_choice_url unless current_user.consumer?
  end

  # (before-filter) ensures that the session belongs to a server
  def authenticated_as_server
    authenticated_as_user
    return if performed?

    bounce_user unless current_user.server?
  end
end
