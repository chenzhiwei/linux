log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/var/chef/chef-repo/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/var/chef/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://server.chef.com'
cache_type               'BasicFile'
syntax_check_cache_path  '/var/chef/chef-repo/.chef/syntax_check_cache'
cookbook_path            [ '/var/chef/chef-repo/cookbooks' ]
