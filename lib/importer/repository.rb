module Importer
  class Repository
    attr_reader :repo

    def self.process(text, source)
      repos = text.scan(/(?:https?\:\/\/)(#{source})\/
        ([^),.\/]+)\/([^,\s)(\/]+)\/?([^ )]*)/x)

      repos.map do |repo|
        Repository.new(repo).process
      end
    end

    def initialize(repo)
      @repo = repo
    end

    def username
      repo[1].gsub(/\p{Z}/, "")
    end

    def source
      repo[0]
    end

    def repository_name
      repo[2].gsub(/\.$/, "").gsub(/[\p{Z}​​]/, "")
    end

    def process
      repo_url = "https://#{@source}/#{@username}/#{@repository_name}"
      Tool.where(url: repo_url).first_or_create
    end
  end
end
