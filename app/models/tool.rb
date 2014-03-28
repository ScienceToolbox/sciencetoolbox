require 'open-uri'

class Tool < ActiveRecord::Base
  acts_as_taggable
  before_validation :get_metadata, :unless => Proc.new { |m| m.persisted? }

  has_and_belongs_to_many :users
  has_many :citations
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_presence_of :name

  def repo_name
    case url
    when /^\w+\/\w/
      url
    when /^https?:\/\/github\.com/
      url.match(/https?:\/\/github\.com\/(.*)/)[1]
    when /^https?:\/\/bitbucket\.org/
      url.match(/https?:\/\/bitbucket\.org\/(.*)/)[1]
    end
  end

  def get_metadata
    case url
    when /^\w+\/\w/
      get_github_metadata
    when /^https?:\/\/github\.com/
      get_github_metadata
    when /^https?:\/\/bitbucket\.org/
      get_bitbucket_metadata
    end
    true
  end

  def get_bitbucket_metadata
    begin
      uri = URI('https://bitbucket.org/api/1.0/repositories/' + repo_name)
    rescue
      return false
    end

    begin
      response = open(uri)
    rescue
      return false
    end

    return false if response.status != [200, 'OK']

    response = JSON.parse(response.read)
    response['stargazers_count'] = response['followers_count']
    response['owner_login'] = response['owner']
    response['owner_url'] = "https://bitbucket.org/#{response['owner_login']}"
    self.name = response['name']
    self.metadata = response
    self.description = metadata['description']
    self.tag_list << metadata['language']
    true
  end

  def get_github_metadata
    if repo_name == url
      self.url = 'https://github.com/' + url
    end
    begin
      repo = OCTOKIT.repo(repo_name)
    rescue
      return false
    end
    metadata = repo.to_hash
    metadata[:owner] = metadata[:owner].to_hash
    metadata[:owner_login] = metadata[:owner][:login]
    metadata[:owner_url] = "https://www.github.com/#{metadata[:owner_login]}"
    if metadata[:organization]
      metadata[:organization] = metadata[:organization].to_hash
    end
    self.metadata = metadata
    self.name = metadata[:name]
    self.description = metadata[:description]
    self.tag_list << metadata[:language]
    true
  end

  def provider
    case url
    when /github.com/
      :github
    when /bitbucket.org/
      :bitbucket
    end
  end
end
