require File.expand_path(File.dirname(__FILE__) + "/environment")
# set :output, 'log/cron.log'
set :output, { :error => 'log/whenever.log', :standard => 'log/cron.log' }

# set :environment, :development
# every 1.minute do
#   rake "notifying:notification"
# end

set :environment, :production
every 1.day, at: ['9:00 am', '11:00 pm'] do
  rake "notifying:notification"
end

# every 1.minute do
#   rake "notifying:notification"
# end
