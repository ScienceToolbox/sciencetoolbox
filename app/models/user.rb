require 'open-uri'

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
     if user = User.find_by_email_and_provider(data["email"], 'github')
        user.update_attribute(:oauth_token, auth["credentials"]["token"])
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
     if user = User.find_by_uid_and_provider(data['uid'], 'bitbucket')
      user.update_attributes({
        email: data["email"],
        oauth_token: auth["credentials"]["token"],
        oauth_secret: auth["credentials"]["secret"]
      })
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

  def self.find_or_initialize_from_provider_and_username(provider, username)

    case provider
    when 'github'
      user = User.find_by_nickname_and_provider(username, 'github')
      return user if user
      user = OCTOKIT.user(username).to_hash
      # {:login=>"ucdavis-bioinformatics",
      #  :id=>314754,
      #  :gravatar_id=>"ed6104fbd6c8724de6f95589f0e7e12b",
      #  :type=>"User",
      #  :site_admin=>false,
      #  :name=>"UC Davis Bioinformatics Core",
      #  :company=>nil,
      #  :blog=>"bioinformatics.ucdavis.edu",
      #  :location=>"UC Davis Genome Center, Davis, CA",
      #  :email=>"ucdbio@gmail.com",
      #  :hireable=>false,
      #  :bio=>nil,
      #  :public_repos=>8,
      #  :public_gists=>0,
      #  :followers=>71,
      #  :following=>4,
      #  :created_at=>2010-06-25 19:10:12 UTC,
      #  :updated_at=>2014-02-24 15:52:31 UTC}
      User.create!(
        provider: provider,
        uid: user[:id],
        email: user[:email],
        avatar: "http://www.gravatar.com/avatar/#{user[:gravatar_id]}?s=200",
        nickname: user[:login],
        password: Devise.friendly_token[0,20]
      )
    when 'bitbucket'
      user = User.find_by_nickname_and_provider(username, 'bitbucket')
      user = open('https://bitbucket.org/api/1.0/users/' + username)
      user = JSON.parse(user)
      user = user['user']
      # {
      # "username"=>"petermr",
      # "first_name"=>"",
      # "last_name"=>"",
      # "display_name"=>"petermr",
      # "is_team"=>false,
      # "avatar"=>"https://secure.gravatar.com/avatar/accd1d94994953c5a6e5cff386f2f144?d=https%3A%2F%2Fd3oaxc4q5k2d6q.cloudfront.net%2Fm%2F100dd4fdc110%2Fimg%2Fdefault_avatar%2F32%2Fuser_blue.png&s=32",
      # "resource_uri"=>"/1.0/users/petermr"
      # }
      User.create!(
        provider: provider,
        uid: user['username'],
        email: user['username'] + '@bitbucket.user',
        avatar: user["avatar"],
        nickname: user[:login],
        password: Devise.friendly_token[0,20]
      )
    end
  end
end
