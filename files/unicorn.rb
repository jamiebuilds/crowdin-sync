# Set the working application directory
working_directory "/var/www/crowdin-sync"

# Unicorn PID file location
pid "/var/www/crowdin-sync/pids/unicorn.pid"

# Path to logs
stderr_path "/var/www/crowdin-sync/logs/unicorn.log"
stdout_path "/var/www/crowdin-sync/logs/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.myapp.sock"

# Number of processes
worker_processes 2

# Time-out
timeout 30
