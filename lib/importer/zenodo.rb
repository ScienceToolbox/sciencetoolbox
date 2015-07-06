module Importer
  class Zenodo
    XMLNS = { xmlns: "http://datacite.org/schema/kernel-3" }

    # Long running
    def self.import
      new.import
    end

    def import
      loop do
        @response = open(
          api_url, "User-Agent" => USER_AGENT
        ).read

        @response = Nokogiri::XML(@response)
        @results = @response.css("record")
        results = process_results
        break if results.empty?
        sleep 0.6
      end
    end

    def resumption_token
      @response.css("resumptionToken").text if @response
    end

    def process_results
      @results.map do |result|
        process_result(result)
      end
    end

    def process_result(result)
      doi_css = "xmlns|identifier[identifierType='DOI']"
      relation_css = "xmlns|relatedIdentifier[relationType='IsSupplementTo']"
      cited_css = "xmlns|relatedIdentifier[relationType='IsCitedBy']"

      # GitHub
      result.css(relation_css, XMLNS).each do |url|
        if url.text =~ /github.com/
          process_github_url(url.text)
        else
          doi = result.css(doi_css, XMLNS).first
          # process_other("http://dx.doi.org/#{doi.text}")
        end
      end

      # Citations
      # result.css(cited_css, XMLNS).first.try(:tap) do |url|
      # end

      result
    end

    def process_github_url(url)
      url_parts = url.match(/.*github.com\/(.+?)\/(.+?)(\/|\z)/)
      main_url = "https://github.com/#{url_parts[1]}/#{url_parts[2]}"
      tool = Tool.where(url: main_url).first_or_create
      tool_version = ToolVersion.where(url: url, tool: tool).first_or_create
    end

    def process_other(url)
      tool = Tool.where(url: url).first_or_create
    end

    def api_url
      base_url = "https://zenodo.org/oai2d?verb=ListRecords"
      if resumption_token.present?
        "#{base_url}&resumptionToken=#{resumption_token}"
      else
        "#{base_url}&metadataPrefix=oai_datacite3&set=software"
      end
    end
  end
end
