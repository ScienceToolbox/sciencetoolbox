class Tool < ActiveRecord::Base
  acts_as_taggable
  before_save :get_metadata

  has_and_belongs_to_many :users

  validates_uniqueness_of :url
  validates_presence_of :url

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
    uri = URI('https://bitbucket.org/api/1.0/repositories/' + repo_name)
    response = JSON.parse(Net::HTTP.get(uri)) # => String
    response['stargazers_count'] = response['followers_count']
    response['owner_login'] = response['owner']
    response['owner_url'] = "https://bitbucket.org/#{response['owner_login']}"
    self.metadata = response
    true
  end

  def get_github_metadata
    if repo_name == url
      self.url = 'https://github.com/' + url
    end
    repo = OCTOKIT.repo(repo_name)
    metadata = repo.to_hash
    metadata[:owner] = metadata[:owner].to_hash
    metadata[:owner_login] = metadata[:owner][:login]
    metadata[:owner_url] = "https://www.github.com/#{metadata[:owner_login]}"
    if metadata[:organization]
      metadata[:organization] = metadata[:organization].to_hash
    end
    self.metadata = metadata
    true
  end
end
