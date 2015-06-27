module Importer
  class EuropePmc
    # Long running
    def self.import
      SOURCES.each do |source|
        new(source).import
      end
    end

    def initialize(source)
      @source = source
    end

    def import
      page = 1
      loop do
        response = open(api_url(@source, page), "User-Agent" => USER_AGENT).read
        results = process_results(response)
        page += 1
        break if results.empty?
      end
    end

    def process_results(response)
      results = JSON.parse(response)["resultList"]["result"]
      results.each do |result|
        process_result(result)
      end
    end

    def process_result(result)
      return unless result["doi"]
      urls = urls(result)
      paper = Paper.from(result, urls, @source)
      paper.process
    end

    def urls(result)
      result["fullTextUrlList"]["fullTextUrl"].select do |u|
        u["availability"] == "Free" && u["documentStyle"] == "html" ||
          u["availability"] == "Open access" && u["documentStyle"] == "html"
      end
    end

    def api_url(query, page)
      "http://www.ebi.ac.uk/europepmc/webservices/rest/search/"\
      "query=#{query}&page=#{page}&resulttype=core&format=json"
    end
  end
end
