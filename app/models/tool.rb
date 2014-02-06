class Tool < ActiveRecord::Base
  acts_as_taggable

  before_save :get_github_metadata

  def repo_name
    if url =~ /^\w+\/\w/
      url
    else
      url.match(/https?:\/\/github\.com\/(.*)/)[1]
    end
  end

  def get_github_metadata
    if repo_name == url
      self.url = 'https://github.com/' + url
    end
    repo = OCTOKIT.repo(repo_name)
    metadata = repo.to_hash
    metadata[:owner] = metadata[:owner].to_hash
    metadata[:owner_login] = metadata[:owner][:login]
    metadata[:organization] = metadata[:organization].to_hash
    self.metadata = metadata
  end
end
