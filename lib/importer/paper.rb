module Importer
  class Paper
    def self.from(result, urls, source)
      begin
        if possible_url.present?
          result = Nokogiri::HTML(
            open(possible_url, "User-Agent" => USER_AGENT).read
          )
          text = result.text
        else
          text = get_by_doi(result)
        end
      rescue
        text = get_by_doi(result)
      end
      text = "#{text} #{result['abstractText']}"

      return Paper.new(result, text, source) if text
    end

    def self.get_by_doi(result)
      begin
        doi = result["doi"]
        Nokogiri::HTML(open(doi_url(doi), "User-Agent" => USER_AGENT).read).text
      rescue => e
        Rails.logger.info(e)
        nil
      end
    end

    def self.doi_url(doi)
      "http://dx.doi.org/" + doi
    end

    def initialize(result, text, source)
      @doi = self.class.doi_url(result["doi"])
      @result = result
      @text = text
      @source = source
    end

    def process

      Repository.process(@text, @source).each do |tool|
        process_citation(tool)
      end
    end

    def date_from_metadata(metadata)
      return unless metadata["issued"]
      date_parts = metadata["issued"]["date-parts"].first
      if date_parts.size < 3
        DateTime.parse("1-1-#{date_parts[0]}")
      else
        DateTime.parse("#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}")
      end
    end

    def process_citation(tool)
      unless Citation.find_by_doi_and_tool_id(@doi, tool.id)

        metadata = open(@doi, "Accept" => "application/json").read
        metadata = JSON.parse(metadata)

        citation = Citation.new(tool: tool)
        citation.authors = @result["authorList"]["author"].map do |a|
          a["fullName"]
        end.join(", ")

        citation.metadata = metadata
        citation.published_at = date_from_metadata(metadata)
        citation.title = metadata["title"]
        citation.doi = @doi
        citation.journal = metadata["container-title"]
        if metadata["subject"]
          citation.tool.tag_list << metadata["subject"].map do |s|
            s.gsub(/\(.+\)/, '')
          end
        end
        citation.tool.save
        citation.save
        puts "Created citation: #{citation.doi}." if citation.persisted?
      end
    end
  end
end
