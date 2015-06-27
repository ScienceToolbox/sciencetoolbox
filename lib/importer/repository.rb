module Importer
  class Repository
    def self.process(text, source)
      repos = text.scan(/(?:https?\:\/\/)(#{source})\/
        ([^),.\/]+)\/([^,\s)(\/]+)\/?([^ )]*)/x)

      repos.map do |repo|
        Repository.new(repo).process
      end
    end

    def initialize(repo)
      @source = repo[0]
      @username = repo[1].gsub(/\p{Z}/, '')
      @repository_name = repo[2].gsub(/\.$/, '').gsub(/[\p{Z}​​]/, '')
    end

    def process
      puts "Looking at #{@source} repo: #{@username}/#{@repository_name}"
      repo_url = "https://#{@source}/#{@username}/#{@repository_name}"

      tool = Tool.find_by_url(repo_url)

      if tool
        puts "Found existing tool: #{tool.name}"
      else
        tool = Tool.create(url: repo_url)
      end
      puts "Created tool: #{tool.name}." if tool.persisted?

      tool
    end
  end
end
