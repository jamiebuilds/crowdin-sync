# Crowdin Sync

У цій документації відображено процес налаштування Crowdin, GitHub та DigitalOcean для синхронізації перекладів у репозиторії.

Якщо ви читаєте не англійський переклад цієї документації, ви все ще можете знайти неперекладені англійські тексти. Якщо ви бажаєте допомогти з будь-яким із перекладів, це можна зробити на платформі Crowdin. Будь ласка, ознайомтесь із [довідкою перекладача](/CONTRIBUTING.md) для детальнішої інформації.

[![cc-by-4.0](https://licensebuttons.net/l/by/4.0/80x15.png)](http://creativecommons.org/licenses/by/4.0/)

## Переклади

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
  * [Pусский](/translations/ru/README.md)
  * [Српски језик (Ћирилица)](/translations/sr/README.md)
  * [Svenska](/translations/sv-SE/README.md)
  * [Türk](/translations/tr/README.md)
  * [Український](/translations/uk/README.md)
  * [Tiếng Việt](/translations/vi/README.md)
  * [中文](/translations/zh-CN/README.md)
  * [繁體中文](/translations/zh-TW/README.md)

**[Надіслати запит на додання відсутньої мови](https://github.com/thejameskyle/crowdin-sync/issues/new?title=Translation%20Request:%20[Please%20enter%20language%20here]&body=I%20am%20able%20to%20translate%20this%20language%20[yes/no])**

## Інструкція

### Налаштування Crowdin

[Створіть обліковий запис в Crowdin](https://crowdin.com/join).

[Створіть проект](https://crowdin.com/createproject).

> Якщо ви не хочете платити Crowdin і ваш проект відповідає необхідним критеріям, ви можете надіслати запит на безкоштовну ліцензію для проектів з відкритим кодом [тут](https://crowdin.com/page/open-source-project-setup-request).

Після створення проекту, перейдіть у вкладку загальних налаштувань:

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#general
    

Встановіть опцію "Дублікати" (Duplicate Strings) на "Показувати, але автоматично перекладати" (Show, but auto-translate them).

Також ви можете дозволити перекладачам створювати терміни в глосарії та надсилати сповіщення про нові тексти для перекладу, а також бути сповіщеними про завершення перекладів на окрему мову. Можливо, навіть захочете завантажити логотип проекту.

Після цього перемкніться у вкладку "Інтеграція" (Integration) і знайдіть секцію "API ключ" (API key). Рекомендується зберегти його для подальшого використання. Будьте обережні з API-ключем, нікому не розголошуйте його. Якщо з певної причини він стане публічним, ви завжди можете відкрити вкладку "Інтеграція" знову і створити новий ключ.

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#integration
    

### Налаштування сервера

Створіть обліковий запис в [Digital Ocean](https://www.digitalocean.com), після чого створіть новий дроплет. Особисто я використовую машину на Ubuntu із 512MB/1 CPU за $5/місяць.

Вам не знадобляться будь-які інші додаткові можливості, але не забудьте додати SSH-ключ для своєї машини для використання SSH у майбутньому.

Після цього назвіть свій дроплет щось на зразок "translations" і клацніть "Create".

Ви опинитесь на сторінці "Дроплетів", де помітите щойно створений дроплет.

Відшукайте секцію "IP Address", ми використовуватимемо її для SSH в дроплеті.

```sh
$ ssh root@[YOUR_DROPLET_IP]
```

Тепер необхідно встановити усі інструменти, необхідні для дроплета.

```sh
$ apt-get install git build-essential g++ make ruby-full nginx unicorn vim
$ gem install crowdin-cli sinatra unicorn
```

> Це може зайняти деякий час.

Тепер перейдіть у директорію `/var/www`, почнемо створювати деякі файли:

```sh
$ cd /var/www
$ mkdir crowdin-sync
$ cd crowdin-sync
$ mkdir logs repos pids keys
$ touch config.ru app.rb unicorn.rb
```

Після цього, заповнимо ці файли наступним кодом:

```sh
$ vim config.ru
```

> Примітка: Для того щоб вставити наступний текст у vim, натисніть кнопку `i`, вставте, натисніть `esc`, після чого надрукуйте `:wq`.

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

Тепер ми повинні додати API-ключ від Crowdin для використання на цьому сервері. Для простоти, ми покладемо їх в директорію `keys` у форматі TXT. Це не надто безпечно, тому можливо ви захочете обрати більш надійне рішення.

Створіть файл з вашим ключем.

```sh
$ vim keys/[YOUR_REPO_NAME]
```

    0123456789abcdefghijklmnopqrstuvwxyz
    

Наостанок, налаштуємо nginx.

Видаліть стандартний файл конфігурації

```sh
$ rm -v /etc/nginx/sites-available/default
```

Створіть нову, порожню конфігурацію

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
    

### Налаштування GitHub

Ми працюватимемо із Git напряму. Якщо ви використовуєте GitHub, можливо варто налаштувати бот-аккаунт замість використання звичайного аккаунта.

Йдемо далі: налаштуйте аккаунт на зразок @thejameskylebot який буде поряд із моїм аккаунтом @thejameskyle.

Після цього, налаштуйте SSH-ключі для вашого Digital Ocean дроплета згідно нижчевказаній інструкції:

https://help.github.com/articles/generating-ssh-keys/

Тепер необхідно оновити конфіг git для коміту:

```sh
$ git config --global user.name "thejameskylebot"
$ git config --global user.email "me+bot@thejameskyle.com"
```

На GitHub, надайте своєму боту доступ до push на цій сторінці:

    https://github.com/[YOUR_USER_NAME]/[YOUR_REPO_NAME]/settings/collaboration
    

Перейдіть у свою директорію `repos` і склонуйте репозиторій.

```sh
$ cd /var/www/crowdin-sync/repos
$ git clone git@github.com:[YOUR_USER_NAME]/[YOUR_REPO_NAME].git
```

### Запуск сервера

Перейдіть у свою директорію `crowdin-sync` і запустіть демон (daemon) unicorn.

```sh
$ cd /var/www/crowdin-sync
$ unicorn -c unicorn.rb -D
```

> Примітка: Якщо ви захочете перезапустити свій сервер, просто виконайте команду:
> 
> ```sh
$ kill $(cat pids/unicorn.pid) && unicorn -c unicorn.rb -D
```

І нарешті, ви повинні перезапустити службу nginx.

```sh
$ service nginx restart
```

Тепер ви повинні мати змогу відкрити IP-адресу свого дроплета у веб-браузері.

    http://[YOUR_DROPLET_IP]/
    

    Works!
    

### Налаштування репозиторію

В першу чергу, інструмент синхронізації Crowdin CLI керується файлом конфігурації в форматі YAML.

У своєму репозиторії ви повинні створити файл `crowdin.yaml`.

```sh
$ touch crowdin.yaml
```

Після цього, заповніть файл.

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

> Примітка: Залиште поле `CROWDIN_API_KEY` як є.

Щоб дізнатись, як саме конфігурується секція `files:`, ознайомтесь із [документацією Crowdin CLI](https://github.com/crowdin/crowdin-cli#configuration). Також, ви завжди можете звернутись до [служби підтримки](https://crowdin.com/contacts)..

Тепер закомітьте цей файл і запуште на GitHub.

### Налаштування вебхуків GitHub

Перейдіть на сторінку "Додати вебхук" для вашого репозиторію на GitHub:

    https://github.com/[YOUR_USER_NAME]/[YOUR_REPO_NAME]/settings/hooks/new
    

Тепер необхідно ввести таку інформацію як IP-адреси ваших дроплетів разом із шляхами вебхуків.

    http://[YOUR_DROPLET_IP]/github/[YOUR_REPO_NAME]
    

Збережіть цей вебхук.

Ви відразу ж помітите, що GitHub надсилає цей вебхук і якщо ви перейдете до Crowdin, ви побачите файли, що були вказані у вашому файлі конфігурації `crowdin.yaml`.

Якщо цього не сталось, перегляньте логи.

```sh
$ tail -f /var/www/crowdin-sync/logs/unicorn.log
```

### Налаштування вебхуків Crowdin

Після того як GitHub успішно оновлює будь-які зміни в Crowdin, ми повинні навчити Crowdin повертати переклади.

Перейдіть на сторінку "Інтеграція" (Integration) з налаштувань вашого проекту.

    https://crowdin.com/project/[YOUR_PROJECT_NAME]/settings#integration
    

Прокрутіть сторінку вниз і клацніть по "Налаштувати вебхуки" (Configure Webhooks).

Введіть наступне в кожне поле і натисність кнопку "Update".

    http://[YOUR_DROPLET_IP]/crowdin/[YOUR_REPO_NAME]
    

Практично, це все. Коли переклади будуть оновлені, вони надсилатимуться у ваш репозиторій. Це може зайняти до 10-15 хвилин перш ніж Crowdin надішле оновлені переклади (ймовірно платформа чекає на неактивність впродовж кількох хвилин).

Я рекомендую зачекати перший раз, щоб переконатись що Crowdin автоматично надсилає вебхук. Але якщо ви хочете запустити вебхук вручну, ви завжди можете запустити вебхук по URL в браузері.

    http://[YOUR_DROPLET_IP]/crowdin/[YOUR_REPO_NAME]
    

Знову ж таки, якщо раптом щось піде не за планом чи нічого не відбудеться взагалі, спробуйте детально розглянути лог-файл.

```sh
$ tail -f /var/www/crowdin-sync/logs/unicorn.log
```

### Починайте переклад

Тепер ви можете почати запрошувати людей в Crowdin, просто надавши їм таке посилання:

    https://crowdin.com/project/[YOUR_PROJECT_IDENTIFIER]/invite
    

Рекомендую створити файл `CONTRIBUTING.md` у власному репозиторії, такий же як в моєму. Загалом, ви можете просто скопіювати мій файл, але обов'язково переконайтеся що URL-адреси збігаються з вашим ідентифікатором проекту.

Також ви можете додати зверху документації не на англійській мові повідомлення на зразок:

```md
If you are reading a non-english translation of this document you may still find English sections that have not yet been translated. If you would like to contribute to one of the translations you must do so through Crowdin. Please read the [contributing guidelines](/CONTRIBUTING.md) for more information.
```

А ще я раджу додати перелік усіх мов проекту як зображено на початку документації. Це допоможе звернути увагу потенційних перекладачів до вашого проекту перекладу, а читачам буде приємно читати документацію рідною мовою.

**Вдалих перекладів!**