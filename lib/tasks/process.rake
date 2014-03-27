require 'nokogiri'
require 'json'

namespace :process do
  desc "Process Google Scholar results"
  task gs: :environment do
    html = Nokogiri::HTML(open('full.html'))
    results = html.css('.gs_ri')
    results.each do |result|
      begin
        # sleep(rand(4))

        title = result.css('a').first.text
        # => Full text search engine as scalable k-nearest neighbor recommendation system

        # e.g. J Suchal, P Návrat - Artificial Intelligence in Theory and Practice III, 2010 - Springer
        citation_chunks = result.css('.gs_a').text.split(' - ')

        authors = citation_chunks.first
        # => "J Suchal, P Návrat"
        journal = citation_chunks[1].split(/, (?=\d\d\d\d$)/)[0]
        # => "Artificial Intelligence in Theory and Practice III"
        year = citation_chunks[1].split(/, (?=\d\d\d\d$)/)[1]
        # => 2010

        found_github_results = result.css('.gs_rs').text.
          scan(/(?:https?\:\/\/)github\.com\/([^),.\/]+)\/([^.,)(\/]+)\/?([^ )]*)/)

        unless found_github_results.empty?
          puts "Found GitHuboid things."
          found_github_results.each do |g|

            username = g[0].gsub(/\s/, '')
            repository = g[1].gsub(/\s/, '')
            if !username.empty? && !repository.empty?
              citation = Citation.new
              github_url = "https://github.com/#{username}/#{repository}"
              puts "Found #{github_url}"
              tool = Tool.find_by_url(github_url)
              if tool
                citation.tool = tool
              else
                tool = Tool.new(url: github_url)
                if tool.save
                  citation.tool = tool
                else
                  # Skip the citation if we can't create the tool
                  next
                end
              end

              # Query the CrossRef API
              ref = open("http://search.labs.crossref.org/dois?q=#{URI.escape(title + ' ' + authors)}").read
              ref = JSON.parse(ref)

              filtered = ref.select{|r| r['normalizedScore'] == 100 || r['score'] > 1}.first
              if filtered
                puts "Found citation #{filtered}"
                citation.authors = authors
                citation.metadata = filtered
                if filtered['year']
                  citation.published_at = DateTime.parse("1-1-#{filtered['year']}")
                elsif year
                  citation.published_at = DateTime.parse("1-1-#{year.to_i}")
                end
                citation.title = filtered['title']
                citation.doi = filtered['doi']
                citation.journal = journal

                citation.save
                puts citation.to_yaml
              end
            end
          end
        end
      rescue
        puts "Failed #{result}"
      end
    end

  end
end