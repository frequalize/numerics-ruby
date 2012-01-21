# numerics.io API client for Ruby

A Ruby client for the [numerics.io](https://numerics.io/) metrics API. (The API service is currently in private alpha.)

See also numerics-node and numerics-cli.

## Install

    $ sudo gem install numerics

## Summary

    require 'numerics'

    # global connection with project-specific keys
    Numerics.config :access_key => 'project_access_key', :secret_key => 'project_secret_key'

    # or via a config file in e.g. in a Rails app
    Numerics.config File.join(Rails.root, 'config', 'numerics.yml'), Rails.env	#see sample config file @@todo

    #list of variables in project
    Numerics.list # => []

    # start taking measurements
    Numerics.insert('invites_sent', 3, Time.now, {user_id => 1234}) # => { 'insertions' => 1, 'removals' => 0, 'number' => 1, 'stamp' => '1.0' }
    Numerics.list # => ['invites_sent']
    Numerics.stats('invites_sent') # => {'total' => 3, 'count' => 1, 'mean' => 3.0, 'min' => 3, 'max' => 3, 'median' => 3, 'mode' => 3}

    # or multiple project-specific connections
    project1_client = Numerics.connect(:access_key => 'project1_access_key', :secret_key => 'project1_secret_key')
    project1_client.list # => []
    project1_client.insert('invites_sent', 3, Time.now, {user_id => 1234})
 
    project2_client = Numerics.connect('project2_access_key', 'project2_secret_key')
    project1_client.list # => []
    # ...


## Useful for

  * Measuring Anything
  * Monitoring business processes
  * ...
