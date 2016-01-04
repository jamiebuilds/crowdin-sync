require 'sinatra'

CROWDIN_API_KEY = '[<<< Crowdin API Key >>>]'

get '/' do
  'Works!'
end

get '/crowdin/:repo' do |repo|
  system("""
    cd repos/#{repo} &&
    git pull origin master &&
    CROWDIN_API_KEY=#{CROWDIN_API_KEY} crowdin-cli download &&
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
    CROWDIN_API_KEY=#{CROWDIN_API_KEY} crowdin-cli upload sources --auto-update -b master
  """)
  'Done.'
end
