class Group
  include Mongoid::Document
  field :name, type: String
  field :id, type: String
  embeds_many :messages
end

class Message
  include Mongoid::Document
  field :content, type: String
  field :id, type: String
  belongs_to :group
  embeds_one :user
end

class User
  include Mongoid::Document
  field :name, type: String
  field :id, type: String
  belongs_to :message
end
  
