# Crowdin Sync

This document covers how to setup Crowdin, GitHub, and DigitalOcean to sync translations in a repository.

If you are reading a non-english translation of this document you may still find english sections that have not yet been translated. If you would like to contribute to one of the translations you must do so through Crowdin. Please read the [contributing guidelines](/CONTRIBUTING.md) for more information.

[![cc-by-4.0](https://licensebuttons.net/l/by/4.0/80x15.png)](http://creativecommons.org/licenses/by/4.0/)

## Translations

  * [English](/README.md)
  * [Afrikaans](/translations/af/README.md)
  * [العربية](/translations/ar/README.md)
  * [Català](/translations/ca/README.md)
  * [Čeština](/translations/cs/README.md)
  * [Danske](/translations/da/README.md)
  * [Deutsch](/translations/de/README.md)
  * [ελληνικά](/translations/el/README.md)
  * [Español](/translations/es-ES/README.md)
  * [Suomi](/translations/fi/README.md)
  * [Français](/translations/fr/README.md)
  * [עִברִית](/translations/he/README.md)
  * [Magyar](/translations/hu/README.md)
  * [Italiano](/translations/it/README.md)
  * [日本語](/translations/ja/README.md)
  * [한국어](/translations/ko/README.md)
  * [Norsk](/translations/no/README.md)
  * [Nederlands](/translations/nl/README.md)
  * [Português](/translations/pl/README.md)
  * [Português (Brasil)](/translations/pt-BR/README.md)
  * [Portugisisk](/translations/pt-PT/README.md)
  * [Română](/translations/ro/README.md)
  * [Русский](/translations/ru/README.md)
  * [Српски језик (Ћирилица)](/translations/sr/README.md)
  * [Svenska](/translations/sv-SE/README.md)
  * [Türk](/translations/tr/README.md)
  * [Український](/translations/uk/README.md)
  * [Tiếng Việt](/translations/vi/README.md)
  * [中文](/translations/zh-CN/README.md)
  * [繁體中文](/translations/zh-TW/README.md)

**[Request another translation](https://github.com/thejameskyle/crowdin-sync/issues/new?title=Translation%20Request:%20[Please%20enter%20language%20here]&body=I%20am%20able%20to%20translate%20this%20language%20[yes/no])**

## Guide

### Setting up Crowdin

[Create a Crowdin account](https://crowdin.com/join).

[Create a project](https://crowdin.com/createproject).

> If you do not want to pay for Crowdin and you qualify you may request an open source project [here](https://crowdin.com/page/open-source-project-setup-request).

Once you have created your project visit the General Settings page:

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#general
    

Change "Duplicate Strings" to "Show, but auto-translate them".

You may also want to allow translators to create glossary terms and send notifications about new strings and project completion. Maybe even upload a project logo.

Next go to the "Integration" page for your project and find the "API key". You'll want to save this for later. Be careful what you do with this api key, it is supposed to be secret. If you expose it for any reason, you can go back to this page to regenerate it.

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#integration
    

### Setting up your server

Create a [Digital Ocean](https://www.digitalocean.com) account and then create a new droplet. I chose to use Ubuntu with the $5/mo 512MB/1 CPU tier.

You don't need any special features, but make sure to add an SSH key for your machine so you can SSH in later.

Then just name your droplet something like "translations" and click "Create".

You should be taken to your "Droplets" page where you will see your newly created droplet.

Find the "IP Address" and we'll use it to SSH into the droplet.

```sh
$ ssh root@[YOUR_DROPLET_IP]
```

Now we'll install all the tools that we will need for this droplet.

```sh
$ apt-get install git build-essential g++ make ruby-full nginx unicorn vim
$ gem install crowdin-cli sinatra unicorn
```

> This is probably going to take awhile.

Now cd into the `/var/www` directory and we'll start creating some files:

```sh
$ cd /var/www
$ mkdir crowdin-sync
$ cd crowdin-sync
$ mkdir logs repos pids keys
$ touch config.ru app.rb unicorn.rb
```

Then let's populate these files with code:

```sh
$ vim config.ru
```

> Note: To paste the following text into vim, hit the `i` key, paste, hit `esc` and then type `:wq`.

```ruby
require 'rubygems'
require './app'

run Sinatra::Application
```

```sh
$ vim unicorn.rb
```

```ruby
# Set the working application directory
# working_directory "/path/to/your/crowdin-sync"
working_directory "/var/www/crowdin-sync"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/var/www/crowdin-sync/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "/var/www/crowdin-sync/logs/unicorn.log"
stdout_path "/var/www/crowdin-sync/logs/unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.crowdinsync.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30
```

```sh
$ vim app.rb
```

```ruby
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

```

Now we need to add the Crowdin api key for this server to use. For simplicity we are just putting them in a `keys` directory in plain text. This is not secure and you may want to setup something better than that.

Create a file with your key.

```sh
$ vim keys/[YOUR_REPO_NAME]
```

    0123456789abcdefghijklmnopqrstuvwxyz
    

Finally we need to setup nginx.

Remove the default configuration file

```sh
$ rm -v /etc/nginx/sites-available/default
```

Create a new, blank configuration

```sh
$ vim /etc/nginx/conf.d/default.conf
```

    upstream app {
        # Path to Unicorn SOCK file, as defined previously
        server unix:/tmp/unicorn.crowdinsync.sock fail_timeout=0;
    }
    
    server {
    
    
        listen 80;
    
        # Set the server name, similar to Apache's settings
        server_name localhost;
    
        # Application root, as defined previously
        root /var/www/crowdin-sync/public;
    
        try_files $uri/index.html $uri @app;
    
        location @app {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_redirect off;
            proxy_pass http://app;
        }
    
        error_page 500 502 503 504 /500.html;
        client_max_body_size 4G;
        keepalive_timeout 10;
    
    }
    

### Setting up GitHub

We're going to be working with Git directly, if you're using GitHub you might want to setup a bot account instead of using your normal account.

Go ahead and create an account like @thejameskylebot that goes along with my @thejameskyle account.

Then follow this guide to setting up SSH keys from your Digital Ocean droplet:

https://help.github.com/articles/generating-ssh-keys/

Now update your git config for committing:

```sh
$ git config --global user.name "thejameskylebot"
$ git config --global user.email "me+bot@thejameskyle.com"
```

And on GitHub give your bot push permission by going to this page:

    https://github.com/[YOUR_USER_NAME]/[YOUR_REPO_NAME]/settings/collaboration
    

Now go to your `repos` directory and clone the repo.

```sh
$ cd /var/www/crowdin-sync/repos
$ git clone git@github.com:[YOUR_USER_NAME]/[YOUR_REPO_NAME].git
```

### Starting your server

Now cd into your `crowdin-sync` directory and start a unicorn daemon.

```sh
$ cd /var/www/crowdin-sync
$ unicorn -c unicorn.rb -D
```

> Note: If you ever want to restart your server simply run:
> 
> ```sh
$ kill $(cat pids/unicorn.pid) && unicorn -c unicorn.rb -D
```

Finally you just need to restart the nginx service.

```sh
$ service nginx restart
```

Now you should be able to open your droplets IP address in a web browser.

    http://[YOUR_DROPLET_IP]/
    

    Works!
    

### Setting up Repo

The Crowdin CLI is controlled primarily through a YAML file.

In your repository create a `crowdin.yaml` file.

```sh
$ touch crowdin.yaml
```

Then fill out the file.

```yaml
project_identifier: [YOUR_PROJECT_NAME]
api_key_env: CROWDIN_API_KEY
base_path: .
files:
  - source: '/README.md'
    translation: '/translations/%locale%/%original_file_name%'
    languages_mapping:
      locale:
        'es-ES': 'es-ES'
        'zh-CN': 'zh-CN'
```

> Note: Leave `CROWDIN_API_KEY` as is.

For information on how to configure `files:` consult the [Crowdin CLI docs](https://github.com/crowdin/crowdin-cli#configuration).

Now commit this file and push it to GitHub.

### Setting up GitHub Webhooks

Go to the "Add webhook" page for your repo on GitHub:

    https://github.com/[YOUR_USER_NAME]/[YOUR_REPO_NAME]/settings/hooks/new
    

Enter the payload as your droplets ip address followed by the webhook path.

    http://[YOUR_DROPLET_IP]/github/[YOUR_REPO_NAME]
    

Save this webhook.

You'll notice that right away GitHub calls this webhook and if you go to Crowdin you should see the files you set in your `crowdin.yaml` file.

If this is not the case, take a look at your log file.

```sh
$ tail -f /var/www/crowdin-sync/logs/unicorn.log
```

### Setting up Crowdin Webhooks

Now that we have GitHub pushing changes to Crowdin, we need to get Crowdin sending translations back.

Go back to the "Integration" page for your project.

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#integration
    

Scroll down and click "Configure Webhooks".

Enter the following in each field and click "Update".

    http://[YOUR_DROPLET_IP]/crowdin/[YOUR_REPO_NAME]
    

This should be it. When translations get updated they should be sent to your repo. It may take up to 10-15 minutes for Crowdin to send the updated translations (I believe they may wait for no activity for a few minutes).

I would recommend waiting the first time to make sure that Crowdin is calling the webhook, but if you ever want to manually trigger the webhook yourself you can simply visit the webhook url in the browser.

    http://[YOUR_DROPLET_IP]/crowdin/[YOUR_REPO_NAME]
    

Again if anything goes wrong or nothing happens try tailing your log file.

```sh
$ tail -f /var/www/crowdin-sync/logs/unicorn.log
```

### Begin translating

Now you can start inviting people to Crowdin by giving them the following url:

    https://crowdin.com/project/[YOUR_PROJECT_IDENTIFIER]/invite
    

I would recommend creating a `CONTRIBUTING.md` file in your repo like the one here. If fact, you can simply copy the one in here, but be sure to update the urls with your own project id.

You can also a message at the top of your documentation for the non-english versions like this:

```md
If you are reading a non-english translation of this document you may still find
english sections that have not yet been translated. If you would like to
contribute to one of the translations you must do so through Crowdin. Please
read the [contributing guidelines](/CONTRIBUTING.md) for more information.
```

I would also suggest you add a list of languages like the one above, it brings attention to the translations to potential translators, and readers who might not otherwise know about the translations.

**Happy translating!**