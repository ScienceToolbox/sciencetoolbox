require 'nokogiri'
require 'json'
require 'open-uri'

namespace :process do
  desc "Process EuropePMC"
  task europe_pmc: :environment do
    #sources = ['bitbucket.org', 'github.com']
    sources = ['github.com']
    sources.each do |source|
      page = 9
      results = ['woot']
      while !results.empty?
        puts "Processing page #{page}."
        user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1907.0 Safari/537.36"
        api_url = "http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=#{source}&dataset=fulltext&page=#{page}&resultType=core&format=json"
        response = open(api_url, 'User-Agent' => user_agent).read
        results = JSON.parse(response)['resultList']['result']
        results.each do |result|
          title = result['title']
          doi = result['doi']
          next unless doi
          authors = result['authorList']['author'].map{|a| a['fullName']}.join(', ')
          journal = result['journalInfo']['journal']['title']
          paper_url = doi = 'http://dx.doi.org/' + doi

          begin
            possible_url = result['fullTextUrlList']['fullTextUrl'].
              select{|u| u['availability'] == 'Free' && u['documentStyle'] == 'html' ||
                u['availability'] == 'Open access' && u['documentStyle'] == 'html'
              }
            paper = Nokogiri::HTML(open(possible_url, 'User-Agent' => user_agent).read)
            paper = paper.text + result['abstractText']
          rescue
            paper = result['abstractText']
          end

          begin
            paper = Nokogiri::HTML(open(paper_url, 'User-Agent' => user_agent).read)
            paper = paper.text + result['abstractText']
          rescue
            paper = result['abstractText']
          end

          next unless paper

          repos = paper.scan(/(?:https?\:\/\/)#{source}\/([^),.\/]+)\/([^,\s)(\/]+)\/?([^ )]*)/)
          repos.each do |repo|

            username = repo[0].gsub(/\p{Z}/, '')
            repository_name = repo[1].gsub(/\.$/, '').gsub(/[\p{Z}​​]/, '')
            puts "Looking at #{source} repo: #{username}/#{repository_name}"

            citation = Citation.new
            repo_url = "https://#{source}/#{username}/#{repository_name}"
            tool = Tool.find_by_url(repo_url)
            if tool
              citation.tool = tool
              puts "Found existing tool: #{citation.tool.name}"
            else
              tool = Tool.create(url: repo_url)
              citation.tool = tool
              puts "Created tool: #{tool.name}." if tool.persisted?
            end
            puts "Looking at citation #{doi}."

            next unless tool.persisted?
            next if Citation.find_by_doi_and_tool_id(doi, tool.id)

            begin
              metadata = open(doi, 'Accept' => 'application/json').read
            rescue
              next
            end
            metadata = JSON.parse(metadata)

            citation.authors = authors
            citation.metadata = metadata
            if metadata['issued']
              date_parts = metadata['issued']['date-parts'].first
              if date_parts.size < 3
                citation.published_at = DateTime.
                  parse("1-1-#{date_parts[0]}")
              else
                citation.published_at = DateTime.
                  parse("#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}")
              end
            end
            citation.title = metadata['title']
            citation.doi = doi
            citation.journal = metadata['container-title']
            if metadata['subject']
              citation.tool.tag_list << metadata['subject'].map{|s| s.gsub(/\(.+\)/, '')}
            end
            citation.tool.save
            citation.save
            puts "Created citation: #{citation.doi}." if citation.persisted?
          end
        end
        page += 1

      end

    end


  end

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

              filtered = ref.select{|r| r['normalizedScore'] == 100 || r['score'] > 3}.first
              if filtered
                puts "Found citation #{filtered}"
                next if Citation.find_by_doi_and_tool_id(filtered['doi'], tool.id)
                metadata = open(filtered['doi'], 'Accept' => 'application/json').read
                metadata = JSON.parse(metadata)
                citation.metadata = metadata

                if metadata['author']
                  citation.authors = metadata['author'].map do |a|
                    a['given'] + ' ' + a['family']
                  end.join(', ')
                end
                if metadata['issued'] && metadata['issued']['date-parts'].flatten != [nil]
                  date_parts = metadata['issued']['date-parts'].first
                  if date_parts.size < 3
                    citation.published_at = DateTime.
                      parse("1-1-#{date_parts[0]}")
                  elsif date_parts.size == 3
                    citation.published_at = DateTime.
                      parse("#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}")
                  end
                else
                  citation.published_at = DateTime.parse("1-1-#{year}")
                end
                citation.title = metadata['title']
                citation.doi = filtered['doi']
                citation.journal = metadata['container-title']
                if metadata['subject']
                  citation.tool.tag_list << metadata['subject'].map{|s| s.gsub(/\(.+\)/, '')}
                  citation.tool.save
                end

                citation.save
                puts citation.to_yaml
              end
            end
          end
        end
      rescue Exception => e
        # binding.pry
        puts "Failed #{result}"
      end
    end

  end
end