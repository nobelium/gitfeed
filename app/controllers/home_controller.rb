class HomeController < ApplicationController
  def index
    github_config = YAML::load(File.open("#{Rails.root}/config/github.yml"))
    fb_config     = YAML::load(File.open("#{Rails.root}/config/fb.yml"))

    github = Github.new(
                        :client_id => github_config["development"]["app_id"],
                        :client_secret => github_config["development"]["app_secret"]
                        )

    fb_auth = FbGraph::Auth.new(
                                  fb_config["development"]["app_id"],
                                  fb_config["development"]["app_secret"])
    fb_client = fb_auth.client



    if session[:user_id].nil?
      @github_login_url = github.authorize_url(
                                              :redirect_uri => 'http://seekshiva.in:3000/home/github',
                                              :scope => github_config["development"]["scope"]
                                              )
      fb_client.redirect_uri = "http://seekshiva.in:3000/home/fb/"
      
      @fb_login_url = fb_client.authorization_uri(
                                                 :scope => fb_config["development"]["scope"]
                                                 )
    else
      @user = User.find(session[:user_id])
      if @user[:github_access_token]..nil?
        github_login_url = github.authorize_url :redirect_uri => 'http://seekshiva.in:3000/home/github', :scope => 'repo'
      else
        
      end
    end
    
    

    respond_to do |format|
      format.html { render "home/dashboard" }
    end
  end


  def github_callback
    github_config = YAML::load(File.open("#{Rails.root}/config/github.yml"))

    github = Github.new(
                        :client_id => github_config["development"]["app_id"],
                        :client_secret => github_config["development"]["app_secret"]
                        )
    
    github_token = github.get_token(params[:code])

    github = Github.new :oauth_token => github_token.instance_variable_get("@token")

    g_user = github.users.get

    handle = user.instance_variable_get("@response").instance_variable_get("@env")[:body].login

    begin
      search_user = User.find_by_github_handle( handle )
      session[:user_id] = search_user.id
    rescue
      new_user = User.new(
               :github_handle => handle,
               :github_access_token =>  github_token
               )
      session[:user_id] = new_user.id
    end
      
    redirect_to root_path
  end

  def fb_callback

  end
end
