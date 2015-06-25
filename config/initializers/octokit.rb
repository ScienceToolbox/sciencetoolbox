OCTOKIT = Octokit::Client.new \
  :client_id     => ENV['ST_GITHUB_CLIENT_ID'],
  :client_secret => ENV['ST_GITHUB_CLIENT_SECRET']
