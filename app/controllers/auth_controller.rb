class AuthController < ApplicationController
  def index
    @oauth = Koala::Facebook::OAuth.new('1736802146607522','b17e461faf7cd2b00d7f517ef93a2320','http://localhost:3000/')
    @URL = @oauth.url_for_oauth_code(:permission => "user_managed_groups")
    
    if( params[:code] )
      @token = @oauth.get_access_token(params[:code])
      session[:token] = @token
    end
  end

end
