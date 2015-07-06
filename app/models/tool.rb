require 'open-uri'

class Tool < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  index_name [Rails.env, self.model_name.singular].join("_")

  acts_as_taggable
  before_validation :get_metadata, :unless => Proc.new { |m| m.persisted? }
  before_validation :check_health, :unless => Proc.new { |m| m.persisted? }
  before_validation :calculate_reproducibility_score, :unless => Proc.new { |m| m.persisted? }

  after_save :invalidate_cache
  has_and_belongs_to_many :users
  has_many :citations
  has_many :tool_versions
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_presence_of :name

  # Elasticsearch serialization
  def as_indexed_json(options={})
    self.as_json(
      include:  {
                  tags: { only: :name},
                  citations: { only: [:title, :authors] },
                }
    )
  end

  def invalidate_cache
    Rails.cache.clear
  end

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

  def check_health
    begin
      case provider
      when :bitbucket
        data = JSON.parse RestClient.get "https://bitbucket.org/api/1.0/repositories/#{repo_name}/src/master/"
        path_key = 'path'
        directories = []
        data['directories'].each {|directory| directories.push({'path' => directory})}
        contents = directories + data['files']
      when :github
        contents = JSON.parse RestClient.get "https://api.github.com/repos/#{repo_name}/contents",
        {:params =>
          {
            :client_id => ENV["GITHUB_CLIENT_ID"],
            :client_secret => ENV["GITHUB_CLIENT_SECRET"]
          }
        }
        path_key = 'name'
      end
      _readme = false
      _license = false
      _virtualization = false
      _ci = false
      _test = false

      contents.each do |content|
        contentname = content[path_key].chomp(File.extname(content[path_key])).downcase
        if _readme == false then _readme = ['readme', 'install', 'notes'].include? contentname end
        if _license == false then _license = ['license', 'copying', 'gpl3'].include? contentname end
        if _virtualization == false then _virtualization = ['vagrantfile', 'dockerfile'].include? contentname end
        if _ci == false then _ci = ['.travis', '.drone'].include? contentname end
        if _test == false then _test = ['test'].include? contentname end
      end

      self.readme = _readme
      self.license = _license
      self.virtualization = _virtualization
      self.ci = _ci
      self.test = _test
    rescue Exception => e
      puts e
    end
    true
  end

  def calculate_reproducibility_score
    self.reproducibility_score = 0
    self.reproducibility_score += 1 if readme
    self.reproducibility_score += 1 if license
    self.reproducibility_score += 1 if virtualization
    self.reproducibility_score += 1 if ci
    self.reproducibility_score += 1 if test
    true
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

    return false if response.status != ['200', 'OK']

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

  def citations_count
    citations.count
  end
end
