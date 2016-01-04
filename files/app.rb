require 'sinatra'

get '/' do
  'Works!'
end

get '/crowdin/:repo' do |repo|
  system("""
    cd repos/#{repo} &&
    git pull origin master &&
    CROWDIN_API_KEY=$(cat ../../keys/#{repo}) crowdin-cli download &&
    git add -A &&
    git commit -m '[i18n] Sync Translations' &&
    git push origin master
  """)
  'Done.'
end

post '/github/:repo' do |repo|
  system("""
    cd repos/#{repo} &&
    git pull origin master &&
    CROWDIN_API_KEY=$(cat ../../keys/#{repo}) crowdin-cli upload sources --auto-update -b master
  """)
  'Done.'
end
