class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        h_page = home_page
        if h_page == "dashboard"
          user = User.find(session[:user_id])
          github = Github.new :oauth_token => user[:github_access_token]
          @str = ""
          @repos = github.repos
          @my_repos = Hash.new
          Subscribe.find_all_by_user_id(session[:user_id]).each do |sub|
            @my_repos[sub[:repo_fullname]] = true
          end

        end
        render "home/#{home_page}"
      }
      
    end
  end


  def github_callback
    github_config = YAML::load(File.open("#{Rails.root}/config/github.yml"))

    github = Github.new(
                        :client_id => github_config["development"]["app_id"],
                        :client_secret => github_config["development"]["app_secret"]
                        )
    
    github_token = github.get_token(params[:code]).instance_variable_get("@token")

    github = Github.new :oauth_token => github_token

    g_user = github.users.get

    handle = g_user.instance_variable_get("@response").instance_variable_get("@env")[:body].login


    p github_token

    begin
      search_user = User.find_by_github_handle( handle )
      session[:user_id] = search_user.id
    rescue

      attributes = { :github_handle => handle, :github_access_token =>  github_token }
                            
      if session[:user_id].nil?
        new_user = User.new attributes
        new_user.save
        session[:user_id] = new_user.id
      else
        user = User.find(session[:id])
        user.update_attributes attributes
        user.save
      end

    end
      
    redirect_to root_path
  end

  def fb_callback
    fb_config     = YAML::load(File.open("#{Rails.root}/config/fb.yml"))

    fb_auth = FbGraph::Auth.new(
                                  fb_config["development"]["app_id"],
                                  fb_config["development"]["app_secret"])

    fb_client = fb_auth.client
    fb_client.redirect_uri = "http://seekshiva.in:3000/home/fb/"
    fb_client.authorization_code = params[:code]


    fb_token = fb_client.access_token! :client_auth_body
    fb_user = FbGraph::User.me(fb_token).fetch
    
    fb_auth.exchange_token! fb_token

    userid = fb_user.instance_variable_get("@raw_attributes")[:id]
    username = fb_user.instance_variable_get("@raw_attributes")[:username]
    
    begin
      search_user = User.find_by_fb_userid( userid )
      session[:user_id] = search_user.id
    rescue
      attributes = { :fb_userid => userid,
        :fb_username => username,
        :fb_access_token => fb_auth.access_token.instance_variable_get("@access_token")
      }
      if session[:user_id].nil?
        new_user = User.new attributes
        new_user.save
        session[:user_id] = new_user.id
      else
        user = User.find(session[:user_id])
        user.update_attributes attributes
        user.save
      end
    end
      
    redirect_to root_path
    
  end

  def home_page
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
      return "signup"
    else
      @user = User.find(session[:user_id])
      
      if @user[:github_handle].nil?
        @github_login_url = github.authorize_url :redirect_uri => 'http://seekshiva.in:3000/home/github', :scope => 'repo'
        
        return "signup"
      elsif @user[:fb_userid].nil?
        fb_client.redirect_uri = "http://seekshiva.in:3000/home/fb/"
        
        @fb_login_url = fb_client.authorization_uri(
                                                    :scope => fb_config["development"]["scope"]
                                                    )
        return "signup"
      else
        return "dashboard"
      end
    end
    
  end
end
