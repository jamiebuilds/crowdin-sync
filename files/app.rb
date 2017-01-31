require 'sinatra'

def githubsync (repo)
  system("""
    cd repos/#{repo} &&
    git fetch origin master -p &&
    git reset --hard origin/master &&
    CROWDIN_API_KEY=$(cat ../../keys/#{repo}) crowdin-cli upload sources --auto-update -b master
  """)
  'Done.'
end

get '/' do
  'Works!'
end

get '/crowdin/:repo' do |repo|
  system("""
    cd repos/#{repo} &&
    git fetch origin master -p &&
    git reset --hard origin/master &&
    CROWDIN_API_KEY=$(cat ../../keys/#{repo}) crowdin-cli download -b master &&
    git add -A &&
    git commit -m '[i18n] Sync Translations' &&
    git push origin master
  """)
  'Done.'
end

# allows manually triggering github sync from web
get '/github/:repo' do |repo|
  githubsync(repo)
end

post '/github/:repo' do |repo|
  githubsync(repo)
end
