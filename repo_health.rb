require 'rest_client'
require 'json'

def check_health(contents, path_key)
  readme = false
  license = false
  virtualization = false
  ci = false
  test = false
  contents.each do |content|
    print "#{content}\n"
    contentname = content[path_key].chomp(File.extname(content[path_key])).downcase
    if readme == false then readme = ['readme', 'install', 'notes'].include? contentname end
    if license == false then license = ['license', 'copying'].include? contentname end
    if virtualization == false then virtualization = ['Vagrantfile', 'Dockerfile'].include? contentname end
    if ci == false then ci = ['.travis', '.drone'].include? contentname end
    if test == false then test = ['test'].include? contentname end
  end
  result = {'readme' => readme, 'license' => license, 'virtualization' => virtualization, 'ci' => ci, 'test' => test}
  return result
end

# Github
user = 'bionode'
repo = 'bionode'
data = JSON.parse RestClient.get "https://api.github.com/repos/#{user}/#{repo}/contents", {:params => {:client_id => ENV['ST_GITHUB_CLIENT_ID'], 'client_secret' => ENV['ST_GITHUB_CLIENT_SECRET']}}
path_key = 'name'
contents = data
check_health(contents, path_key)


#Bit bucket
user = 'petermr'
repo = 'pdf2svg'
data = JSON.parse RestClient.get "https://bitbucket.org/api/1.0/repositories/#{user}/#{repo}/src/default/"
path_key = 'path'
directories = []
data['directories'].each {|directory| directories.push({'path' => directory})}
contents = directories + data['files']
check_health(contents, path_key)
