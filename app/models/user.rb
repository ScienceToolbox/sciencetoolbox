class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :omniauth_providers => [:github, :twitter, :bitbucket]

  has_and_belongs_to_many :tools
  has_many :citations, :through => :tools

  after_create :find_tools

  def find_tools
    Tool.find_each do |tool|
      case tool.url
      when /github\.com/
        if tool.metadata["owner_login"] == nickname
          tool.users << self
        end
      when /bitbucket\.org/
        if tool.metadata["owner_login"] == nickname
          tool.users << self
        end
      end
      tool.save
    end
  end

  def self.find_for_github_oauth(auth)
     data = auth['info']
     if user = User.find_by_email(data["email"])
       user
     else
        User.create!(
          provider: 'github',
          uid: auth['uid'],
          email: data["email"],
          password: Devise.friendly_token[0,20],
          nickname: data["nickname"],
          avatar: data["image"],
          oauth_token: auth["credentials"]["token"]
        )
    end
  end

  def self.find_for_bitbucket_oauth(auth)
     data = auth['info']
     if user = User.find_by_email(data["email"])
       user
     else
        User.create!(
          provider: 'bitbucket',
          uid: auth['uid'],
          email: data["email"],
          password: Devise.friendly_token[0,20],
          nickname: auth["uid"],
          avatar: data["avatar"],
          oauth_token: auth["credentials"]["token"],
          oauth_secret: auth["credentials"]["secret"]
        )
    end
  end
end
