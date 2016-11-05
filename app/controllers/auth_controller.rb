require 'group'
class AuthController < ApplicationController
  def index
    @oauth = Koala::Facebook::OAuth.new('1736802146607522','b17e461faf7cd2b00d7f517ef93a2320','http://localhost:3000/auth/get_token')
    @URL = @oauth.url_for_oauth_code(:permission => "user_managed_groups")
  end
  def get_token

    @oauth = Koala::Facebook::OAuth.new('1736802146607522','b17e461faf7cd2b00d7f517ef93a2320','http://localhost:3000/auth/get_token')
    @token = @oauth.get_access_token(params[:code])
    session[:token] = @token

    redirect_to :action => 'show_groups'
  end
  def show_groups
    if( session.has_key?(:token) )
      @gapi = Koala::Facebook::API.new(session[:token])
      @groups = @gapi.get_connection('me','groups',api_version: "2.6")
    end

  end
  def get_groups
    @gapi = Koala::Facebook::API.new(session[:token])
    @groups = Array(params[:groups])
    @messages = Array.new
    @names = Array.new
    @groups.each do |group|
      page = @gapi.get_connection(group,"feed",{fields: ['message','from','name'] })
      content = Array.new
      while !page.empty?
        content.concat page
        page = page.next_page
      end
      @messages.push(content)
      @names.push(@gapi.get_object(group)['name'])
      
      if Group.where(id: group).exists?
        @group = Group.where(id: group)[0]
      else
        @group = Group.new
        @group.id = group
        @group.name = @names.last
      end
      msgs = @messages.last
      msgs.each do | msg |
        if !msg.key?("message")
          puts "out"
          next
        elsif Message.where(id: msg['id']).exists?
          puts "msg exist"
          next
        end
        @msg = @group.messages.new
        if User.where(id: msg['from']['id']).exists?
          puts "user exist"
          @user = User.where(id: msg['from']['id'])[0]
        else
          puts "new user"
          @user = User.new
          @user.id = msg['from']['id']
          @user.name = msg['from']['name']
          @user.save
        end
        @msg.user = @user
        @msg.content = msg['message']
        @msg.id = msg['id']
        @msg.save
      end
      @group.save
    end
  end
  def get_page
    @gapi = Koala::Facebook::API.new(session[:token])
    @page = @gapi.get_object("nctucs.assoc")
    @msgs = @gapi.get_connection(@page['id'],'feed')
    @msgs.each do |msg|
        m = Post.new
        if !msg.key?("message")
          next
        elsif Post.where(id: msg['id']).exists?
          next
        end
        m.content = msg['message']
        m.id = msg['id']
        m.page_id = @page['id']
        m.create_time = msg['created_time']
        m.save
    end
    @page = @gapi.get_object("nctucs")
    @msgs = @gapi.get_connection(@page['id'],'feed')
    @msgs.each do |msg|
        m = Post.new
        if !msg.key?("message")
          next
        elsif Post.where(id: msg['id']).exists?
          next
        end
        m.content = msg['message']
        m.id = msg['id']
        m.page_id = @page['id']
        m.create_time = msg['created_time']
        m.save
    end
  end
end
