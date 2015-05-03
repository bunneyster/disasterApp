class UsersController < ApplicationController
  before_action :authenticated_as_admin, except:
      [:show, :new, :edit, :create, :update, :choose_role, :role_choice]
  before_action :authenticated_as_user, only: [:show, :edit, :update]
  before_action :set_user, only: [:edit, :update, :destroy]

  # TODO(pwnall): remove this when switching to the gem
  include RecaptchaVerification

  # GET /users
  def index
    @users = User.order(:id).includes(:credentials).page params[:page]

    respond_to do |format|
      format.html  # index.html.erb
    end
  end

  # GET /users/1
  def show
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_read?(current_user)

    respond_to do |format|
      format.html  # show.html.erb
    end
  end

  # GET /users/new
  def new
    @user = User.new

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_edit?(current_user)
  end

  # POST /users
  def create
    @user = User.new user_params
    @user.developer = false
    # NOTE: the first user gets to be an admin, and can make other users admins
    #       or developers
    @user.admin = User.count == 0

    respond_to do |format|
      if verify_recaptcha(model: @user, attribute: :email) && @user.save
        token = Tokens::EmailVerification.random_for @user.email_credential
        SessionMailer.email_verification_email(token, root_url).deliver

        format.html do
          redirect_to session_url,
              alert: 'Please check your e-mail to verify your account.'
        end
      else
        format.html { render action: :new }
      end
    end
  end

  # PUT /users/1
  def update
    @user = User.with_param(params[:id]).first!
    return bounce_user unless @user.can_edit?(current_user)

    respond_to do |format|
      if @user.update_attributes user_admin_params
        flash[:notice] = 'User information successfully updated.'
        format.html { redirect_to @user }
      else
        format.html { render action: :edit }
      end
    end
  end

  # DELETE /users/1
  def destroy
    return bounce_user unless @user.can_edit?(current_user)

    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  # POST /users/1/choose_role/consumer
  def choose_role
    @user = User.with_param(params[:id]).first!
    unless @user.can_edit?(current_user) || @user == current_user
      return bounce_user
    end
    return bounce_user unless @user.undecided?

    @user.kind = params[:role]
    @user.save!

    respond_to do |format|
      format.html do
        redirect_to root_url,
            notice: "You have successfully become a #{params[:role]}"
      end
    end
  end

  # GET /usrs/1/role_choice
  def role_choice
    @user = User.with_param(params[:id]).first!
    unless @user.can_edit?(current_user) || @user == current_user
      return bounce_user
    end
    return bounce_user unless @user.undecided?

    respond_to do |format|
      format.html  # users/role_choice.html.erb
    end
  end

  # Common code for looking up a user in the database.
  def set_user
    @user = User.with_param(params[:id]).first!
  end
  private :set_user

  # Whitelists the fields used for signing up.
  def user_params
    params.require(:user).permit :email, :password, :password_confirmation
  end
  private :user_params


  # Whitelists the fields used by an admin.
  def user_admin_params
    params.require(:user).permit :admin, :developer
  end
end

