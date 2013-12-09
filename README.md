**General notes from Udi**
1. There is absolutely no introduction as to what this project does at all. It's definitely not trivial, so it's completely mandatory. It's more important than setup notes... What's special about counting here?  You can give a few short examples to begin with, to get people interested...  
2. I think you should pay more attention to correct capitalization in beginnings of sentences. Makes things much easier to read. Don't blame me if I didn't do the same in my comments ;)  
3. I generally didn't comment on grammar mistakes (I did found some). I think we should do proofing after the text is more-or-less finalized? Your thoughts?


Count Von Count
=================
![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

Count-von-Count is a counting system that was developed in [FTBPro.com](https://www.ftbpro.com). It can be used to count any action (i.e. number of readers of an article, number of vistiors to a website per day/hour/week) or **metrics**.
It is based on Nginx and Redis, delivering a scalable and **LIVE** system.

What you can do with it?
========================
Here are some ways that we use in [FTBPro.com](https://www.ftbpro.com)

![Some Counters](http://media.tumblr.com/c0508089f2e631613bff664a94599d10/tumblr_inline_mwtdlnw5d21s9eocl.png)

With Count-von-Count you can:

1. Count number of visitors to a site/page.
2. Track number of clicks hourly/daily/weekly/yearly etc...
3. Measure load time in any client and quickly see the slowest clients.
4. Store anykind of Leaderboard, such as top writers, top readers, top countries your visitors are coming from.
5. Anything that can be counted!

Installation
---------------------------------
1. install redis-server (apt-get install redis-server)
2. download and install [OpenResty](http://openresty.org/#Installation). use default settings and directory structure!
3. install git
4. edit openresty's nginx.conf file (by default its in /usr/local/openresty/nginx/conf)
   * add `worker_rlimit_nofile 30000;` at the top level
   * add `include /usr/local/openresty/nginx/conf/include/*;` under the 'http' section

   ```conf
   #nginx.conf
   worker_rlimit_nofile 30000;
 
   http {
      include /usr/local/openresty/nginx/conf/include/*;
      .
      .
      .
   ``` 
5. Script Loader... *Shai's Notes:* Ron, the ScriptLoader is used only for locally running rspec, i think this is a very advanced use case, so we probably should explain it somewhere else.




Deployment
-----------------
provided are 2 options: 

   1. ###remote deployment (using Ruby & [Capistrano](https://github.com/capistrano/capistrano))
   If you have Ruby on your machine, you should probably use this option.

   Edit `deploy.rb` file and set the correct deploy user and your servers ips in the `deploy` and `env_servers` variables.

   **for the first time** run `cap deploy:setup` to bootstrap the server.

   use `cap deploy` to deploy master branch to production.

   use `cap deploy -S env=qa -S branch=bigbird` if you want to deploy to a different environment and/or a different branch.

   2. ###local deployment (using shell scripts)
   SSH into your count-von-count server.

   **for the first time**
     * clone the git repository into your folder of choice (recommended to use our default - /home/deploy/count-von-count/current)
     * run `sudo ./lib/scripts/setup.sh`. if the last 2 output lines are
     
       ~~~
       >>> nginx is running
       >>> redis-server is running
       ~~~
       
       then you should be good to go.
 
   next time after you update the code, SSH to your count-von-count machine, cd to the repository folder, pull the latest code, and then run `sudo ./lib/scripts/reload.sh`



************************************************************************
************************************************************************

Counting - Its easy as 1,2,3
------------------------------
To configure what gets count and how, simply edit the `config/voncount.config` file.
the file is written in standart JSON notation.
for most use-cases you won't even need to write code!

We'll show here some examples that covers all the different options the system support. most of them are real life examples taken from our production environment. 

but first lets start with a general example for the most basic use case:

```JSON
{
  "<ACTION>": {
    "<OBJECT>": [
      {
        "id": "<ID>",
        "count": "<COUNTER>"
      }
    ]
  }
}
````
with this config file, we can make a call to ```http://my-von-count.com/<ACTION>?<ID>=1234```, which will result in having a `<OBJECT>_<ID>` key in our redis DB, with value `{ <COUNTER>: 1 }`

making the same call again, will result in changing the value of `<OBJECT>_<ID>` to `{ <COUNTER>: 2 }`

Ok, so that was probably a bit vague, lets look at some concrete examples:
to get you in context, here is a short description of our domain - 

At [FTBpro](https://www.ftbpro.com) we have `posts`, `users`, and `teams`. 
each `post` is written by a `user` who is the author, and the post "belongs" to several `teams`.

1. ###simple count - post read
   when a `post` gets read, we want to increase a counter for the post's `author` (which is a `user`), so we know how many reads that user got. here is the config file:
   ```JSON
   {
     "reads": {
       "User": [
         {
           "id": "author",
           "count": "reads_got"
         }
       ]
     }
   }
   ```

   the top most level of the configuration JSON keys is the action type that we want to count - `reads`.
   
   `User` is the object for which we want to count the `reads` action.
   
   `id` is the object (e.g. user's) id, and it should be defined in the query string parameters.
   
   `count` is what we count/increase.

   so, with the above configuration, if we make a call to http://my-von-count.com/reads?author=1234 then in the DB we'll have a key `User_1234` with value ``` { reads: 1 } ```
   
   Compared to the general example: 
      * `<ACTION>`  = `reads`
      * `<OBJECT>`  = `User`
      * `<ID>`      = `author`
      * `<COUNTER>` = `reads_got`
     
   So given a `reads` `<ACTION>`, the `reads_got` `<COUNTER>` of the `User` `<OBJECT>` with `<ID>` equals to `author`'s value, will be increase by one.
   
   **Notice** - in the config JSON, the value of `<ACTION>` (`reads`) is a hash, and the value of the `<OBJECT>` (`user`) is an array of hashes.
   
2. ###simple count - multiple objects of the same type
   now lets also count how many posts a user has read.

   ```JSON
   {
     "reads": {
       "User": [
         {
           "id": "author",
           "count": "reads_got"
         },
         {
           "id": "user",
           "count": "reads"
         }
       ]
     }
   }
   ```
  
   the 'reading' user is also a `User` so we define it under the already existing `User` object.

   the user's id is defined in the query string params as the `user` parameter and for him we count `reads`,
   so after a call to http://my-von-count.com/reads?author=1234&user=5678 our DB will look like:
   
   >User_1234: { reads_got: 2 }
   >
   >User_5678: { reads: 1 }
   
3. ###simple count - multiple objects of different types
   We also want to know how many `reads` each `Post` received, so we add the above configuration for `Post` object under the `reads` action, and we add a 'post' id to the query string parameters. 

   ```JSON
   {
      "reads": {
         "User": [
            {
              "id": "author",
              "count": "reads_got"
            },
            {
              "id": "user",
              "count": "reads"
            }
         ],
         "Post": [
            {
              "id": "post",
              "count": "reads"
            }
         ]
      }
   }
   ```
   
   After a call to http://my-von-count.com/reads?user=1234&author=5678&post=888, thats what we'll have in the DB:
   
   >User_1234: { reads_got: 3 }
   >
   >User_5678: { reads: 2 }
   >
   >Post_888:  { reads: 1 }
   
   
4. ###simple count - object with multiple IDs
   At [FTBpro](https://www.ftbpro.com) we are doing daily analytics, so for each `user` we want to know how many posts he read in each day.

   ```JSON
   {
     "reads": {
      .
      .
      .
        "UserDaily": [
           {
              "id": [
                 "user",
                 "day",
                 "month",
                 "year"
              ],
              "count": "reads",
              "expire": 1209600
           }
       ],   
   ```
   
   The `<ID>` of the `UserDaily` object is an **array**, and is composed of 4 parameters, so after a call to
   http://my-von-count.com/reads?user=5678, the DB will have the following key-value 
   >UserDaily_5678_28_11_2013: { reads: 1 }
   
   
   **WAIT A SECOND!** the query string contains only the `user` parameter, where does the other 3 parameters (`day`, `month`, `year`) come from?!? Read more about it on [Request Metadata Parameters Plugins](#request-metadata-parameters-plugins).
   

5. ###simple count - parameter as `<COUNTER>` name
   we can use parameters to determine the `<COUNTER>` name. in that way we can dynamically determine what gets count.
   in this example, we count for an `author` how many reads he had from each country (every week).

   ```JSON
   {
     "reads": {
      .
      .
      .
      "UserWeeklyDemographics": [
        {
          "id": [
            "author",
            "week",
            "year"
          ],
          "count": "{country}"
        }
       ]      
   ```
   You can see we are using the `week` and `year` parameters for the `<ID>` as in the example above, and also the `country` parameter as the `<COUNTER>` name. 
   
   the `country` parameter is explained under [Request Metadata Parameters Plugins](#request-metadata-parameters-plugins).

  \*Its possible to use a parameter name that is passed in the request query string (e.g. `author`, `post`, etc...), and not only the Metadata Parameters!
  
  \* `<COUNTER>` names can be be more complex. lets say we have a `registered` parameter in the request query string, so we can use - `"count": "from_{country}_{registered}"`

   Request Metadata Parameters Plugins
   -----------------------------------
   Sometimes there is need that the key names will consist data that is not part of the request arguments, but is based on the request metadata. Currently, we support 2 types this cases: date_time metadata paramerters and country parameter.    
   The Request Metadata Parameters works a plugin mechanisem. Enabling/disabling plugins can be done by adding/removing the plugin name in `lib/nginx/request_metadata_parameters_plugins/registered_plugins.lua'. Let's dicuss the default plugins which come out of the box.
   
   ### DateTime Plugin
   
   | Parameter Name | Description                                                          |
   |----------------|----------------------------------------------------------------------|
   | *day*          | current day of the month                                             |
   | *yday*         | day index of the year (out of 365)                                   |
   | *week*         | week index of the year (out of 52). week start and end on Mondays.   |
   | *month*        | month index of the year (out of 12)                                  |
   | *year*         | in 4 digits format                                                   |

  ### Adding custom date_time paramaeters
  
  The plugin comes with the arguments that we think are needed. If you want to add your parameters just update `lib/nginx/request_metadata_parameters_plugins/date_time.lua' with the relevant time formation.
   
   ### Country Plugin
   
   | Parameter Name | Description                                                          |
   |----------------|----------------------------------------------------------------------|
   | *country*      | 2-letters country code according to the IP from which the call       |
   
   
  #### Prerequisites
   
   This plugin uses [lua-geoip](https://github.com/agladysh/lua-geoip) and thus the following steps are necessary for this plugin:
   
   1. Install LuaRocks (apt-get install luarocks)
   2. Install lua-geoip (luarocks install lua-geoip)
   3. Install Geoip (sudo apt-get install geoip-bin geoip-database libgeoip-dev)
   4. Make sure to update the geoip.dat. You can use the provided `lib\scripts\update-geoip.sh' script for it. Just add it to your crontab and schedule it to execute at night time.
   
  #### Customize the Country plugin

  You make your changes to `lib/nginx/request_metadata_parameters_plugins/date_time.lua`. For example, if you want to save the name of the country insted of it code, you can use `geoip.name_by_id(id)` method instad of `geoip.code_by_id(id)`

<TODO> Decide if its enabled by default


Architecture
============

Count-von-Count is based on OpenResty, a Nginx based web service, bundled with some useful 3rd party modules. It turns an nginx web server into a powerful web app server using scripts written in Lua programming language. It still has the advantage of the non-blocking I/O but also has the ability to communicate with remote clients such as MySQL, Memcached and also Redis. We are using Redis as our database for this project, leveraging its scalability and reliability.

![alt tag](https://s3-us-west-2.amazonaws.com/action-counter-logs/Count-von-Count.png)

**__NOTICE - if you don't use the default folders as in the instructions, you'll need to edit and change `deploy.rb`, `setup.sh` and  `reload.sh`__**


Log Player
------------
Count-von-count comes with a log player.It is very useful in cases of recovery after system failure or running on old logs with new logic. Its input is access log file (a log file where the Nginx logs each incoming request). It updates the Redis based on the voncount.config.

![alt-tag](https://s3-us-west-2.amazonaws.com/action-counter-logs/LogPlayer.png)


###Popular Scenarios of using it

1. A bug/error in the system. The log player is based on Nginx's access logs which are written even if there is an nginx error.
2. When a new logic is applied and we want to run it on old events.


### Best Practices

1. Set count-von-count on a different server.
2. Update the voncount.config with the relevant actions for the log player. Note that the configuration can be different than the configuration of the "live" server.
3. run the log player: `lua log_player.lua <access_log_path>`

Advacned
---------

##Backups

###Recomended Backup Policy:

1. Every configured amount of time, Redis persists its state to a dump file (dump.rdb). A hourly snapshot of this file should be made.
2. Nginx's access log should be hourly rotated. This can be done with the logrotate Linux tool. More information on this process can be found on the web.
3. Once a week and once a month, create a snapshot of dump.rdb file
4. Once a day, upload all the dump and logs to a remote storage.
5. After some days, the hourly snapshots can be removed, and the weekly and monthly backups should be kept.
6. In case of a disaster, reload Redis with the relevant dump file, and use the log player with the access log.

## Testing

We use [RSpec](http://rspec.info/) for testing. It is recomended to test your counters. A sample spec can be found at  `spec\counting_spec.rb`. 

### Spec Configuration file

The `spec\config\spec_config.yml` consists some setting for the specs. 

 | Config Key             | Default Valude | Description                                                              |
 |---------------------------------------------------------------------------------------------------                 |
 | redis_port             | 6379           | Redis port. The host is defaulted to "localhost". To access redis in the |  |                                         | specs you can user $redis                                                |
 | redis_db               | 0              | Redis database index.                                                    |
 | log_player_integration | true           | Log player integration on/off (more is described later)                  |
 | log_player_redis_db    | 1              | Log player Redis db                                                      |


### Log Player Integration

Count-von-Count uses the specs to test the log player. The log player tries to imittate the Nginx argument parsing , so its important to test it everytime you count things. 

If the specs we write make a request to the Nginx, than we can take advantage of the the access.log file and test the log player. The access.log is given as an input to the log player, which stores the keys in a different database, and than we can that that the 2 databases are the same.

![alt-tag](https://s3-us-west-2.amazonaws.com/action-counter-logs/LogPlayerIntegrator.png)

This behaviour can be turned off from the `spec_config.yml` file. 

Pitfalls & Gotcha
-------------------
(missing params in query string)

GeoIP Plugin
-------------
6) update init.lua with the location of the GeoIP.dat
