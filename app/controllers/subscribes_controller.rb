class SubscribesController < ApplicationController
  # POST /repo/:owner/:repo_name/subscribe
  def subscribe
    user = User.find(session[:user_id])
    all_sub_count = Subscribe.find_all_by_repo_fullname( "#{params[:owner]}/#{params[:repo_name]}" ).count
    
    if all_sub_count == 0
      github = Github.new :oauth_token => user[:github_access_token]
      github.repos.pubsubhubbub.subscribe (
        { :topic => "https://github.com/#{params[:owner]}/#{params[:repo_name]}/events/push",
          :callback => "http://seekshiva.in:3000/feed/#{params[:owner]}/#{params[:repo_name]}/",
          :verify => 'sync',
          :secret => ''})

    end
    sub = Subscribe.new(:user_id => user.id, :repo_fullname => "#{params[:owner]}/#{params[:repo_name]}")
    p sub


    respond_to do |format|
      if sub.save
        format.json { render json: sub, status: :created }
      else
        format.json { render json: sub.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repo/:owner/:repo_name/unsubscribe
  def unsubscribe
    all_sub_count = Subscribe.find_all_by_repo_fullname( "#{params[:owner]}/#{params[:repo_name]}" ).count

    if all_sub_count == 1
      user = User.find(session[:user_id])

      github = Github.new :oauth_token => user[:github_access_token]
      github.repos.pubsubhubbub.unsubscribe (
      { :topic => "https://github.com/#{params[:owner]}/#{params[:repo_name]}/events/push",
        :callback => "http://seekshiva.in:3000/feed/#{params[:owner]}/#{params[:repo_name]}/",
        :verify => 'sync',
        :secret => ''  })
    end
    sub = Subscribe.find_by_repo_fullname("#{params[:owner]}/#{params[:repo_name]}")
    p sub
    p params[:repo_name]
    sub.destroy


    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  def fbpush
 #   p '\n\n\n\n\n\n'
  #  p params[:owner]
   # p '\n\n\n\n\n\n'
    #p params[:repo_name]
   # p '\n\n\n\n\n\n'
#    p params
   # p '\n\n\n\n\n\n'
    user_name = params[:pusher][:name]
    user = User.find_by_github_handle(user_name);
    sub = Subscribe.find_by_repo_fullname("#{params[:owner]}/#{params[:repo_name]}")
    if sub[:user_id] == user.id
   p 'came 2'
      app = FbGraph::Application.new('1398814903665927')
      p app
      me = FbGraph::User.me(user[:fb_access_token])
      p me
      actions = me.og_actions!(
                               app.og_action(:commit),
                               :custom_object => "http://seekshiva.in:3000/fb/#{params[:owner]}/#{params[:repo_name]}/")
     
      p actions
    end
  end
  
  def fbog
    @owner = params[:owner]
    @repo_name = params[:repo_name]
    
    @repo_url = "https://github.com/#{@owner}/#{@repo_name}"
  end
end
