#Count Von Count

![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

Count-von-Count is an open source project that was developed in FTBpro for a gamification project and it turned to be something the can count any kind of action.  It is based on Nginx and Redis, leverages them to create a live, scalable and easy to use counting solution for a wide range of scenarios.


# Table of Contents

* [What it's all about](#what-it's-all-about)
* [General Overview](#general-overview)
* [Getting Started - Counting, Its easy as 1,2,3](#getting-started)
* [Counting Configuration](#counting-configuration)
  * [Counting Options](#counting-options)
    * [Simple Count](#simple-count)
    * [Multiple Objects of The Same Type](#multiple-objects-of-the-same-type)
    * [Multiple Objects of Different Type](#multiple-objects-of-different-types)
    * [Object With Multiple Ids](#object-with-multiple-ids)
    * [Dynamic Count - Parameter as <COUNTER> name](#dynamic-counter-parameter)
    * [Existing Objects, Different Actions](#existing-objects-different-actions)
    * [Ordered Sets (Leaderboard) - Save The Counters Data in Order](#oredered-sets-(leaderboard)
    * [Advance: Custom Functions - Writing Your Own Logic](#advanc:-custon-functions)
    * [Variable Count - Not Just Increase by 1](#variable-count-not-only)

#What it's all about?

Count-von-Count can help you whenver you need to store counters data. His advantage is that he can process thousands of requests a sceond, and update the numbers in real-time, no caching/backbround processes needed.

With Count-von-Count you can:

1. Count number of visitors to a site/page.
2. Track number of clicks hourly/daily/weekly/yearly etc...
3. Measure load time in any client and quickly see the slowest clients.
4. Store anykind of Leaderboard, such as top writers, top readers, top countries your visitors are coming from.
5. Anything that can be counted!

Here are some ways that we use it in [FTBPro.com](https://www.ftbpro.com)

![Some Counters](http://media.tumblr.com/c0508089f2e631613bff664a94599d10/tumblr_inline_mwtdlnw5d21s9eocl.png)

# General Overview 

Count-von-Count is a web server that uses Redis as a database. When a client wants to tell the server on an event that should be counted, he calls it in the following format: <server_ip>/<action_name>?<params>. This calls always return a 1X1 empty pixel, to reduce the overhead in calling it form javascripts clients. 
A configuration file, von_vount.config which is defined in the server, sets the rules of the counting - what to update for each action. The updates are synchronously commited to the dababase.
The sever also has an api for retrieving the data.

#Installation

1. Install redis-server (apt-get install redis-server). You can also use one of your previously installed servers.
2. Download and install [OpenResty](http://openresty.org/#install). use default settings and directory structure!
3. clone count-von-count.
4. If you are not using Redis with his default settings (localhost, port 6479), update `config/system.config` file with the Redis server ip and port.
5. Edit openresty's nginx.conf file (by default its in /usr/local/openresty/nginx/conf)
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
6.  After Installation is complete, you need, for the first time only, to set up the server.
  
  If you are familiar with Ruby and Capistrano, you can skip this section and follow this - [Deploy using Ruby &     Capistrano](#deploy-using-ruby-and-capistrano)
  
  Run `sudo ./lib/scripts/setup.sh`. if the last 2 output lines are
       
         ~~~
         >>> nginx is running
         >>> redis-server is running
         ~~~
         
      then you should be good to go.

7. For the first time and every time you change the config or the code run `sudo ./lib/scripts/reload.sh`
       
# Getting Started - Counting, Its easy as 1,2,3

Now, after you've understood the general overview of how the system works, and you installed & setup your server, you are ready to get your hands really dirty! :-)

The `config/voncount.config` file is the heart of the system, and determines what gets count and how.

The file is written in standart JSON format, and for most use-cases changing it and customizing it to your needs is enough. You won't even need to write code!

We'll show here some examples that covers all the different options the system support. most of them are real life examples taken from our production environment. 

But Let's start with a simple example: Say that you have a blog site and you want to count the number of reads that each blog post gets.
You need to take care for 2 things:

  1. In each post page, put a pixel (or make a call via JavaScript to) - http://my-von-count.com/reads?post=3144 (3144 is a unique identifier of the current post).
  2. Set the following configration:

```JSON
{
  "reads": {
    "Post": [
      {
        "id": "post",
        "count": "num_reads"
      }
    ]
  }
}
````
** don't forget to run the `reload.sh` script after you change the configuration! **

That's it! For each post that gets read you'll have data in the Redis DB of the form
>Post_3144: { num_reads: 5772 }

e.g, to get the number of reads for post 3144 you can run `redis-cli hget Post_3144 num_reads`

Lets see a general example for the most basic use case:

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

#Counting Configuration

As mentioned earlier,`config/voncount.config` file is the heart of the system, and determines what gets count and how. Let's go over the different configration options.

##Counting Options

To get you in context, here is a short description of our domain - 

At [FTBpro](https://www.ftbpro.com) we have `posts`, `users`, and `teams`. 
each `post` is written by a `user` who is the author, and the post "belongs" to a `team`.

### Simple Count
   when a `post` gets read, we want to increase a counter for the post's `author` (an `author` is basically a `User` of our site), so we know how many reads that user got. here is the config file:
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
   
   `id` is the object (e.g. user's) id, and it should be defined in the query string parameters when making a call to the count-von-count server.
   
   `count` is what we count/increase.

   so, with the above configuration, if we make a call to http://my-von-count.com/reads?author=1234 then in the DB we'll have:
   >User_1234: { reads_got: 1 }
   
   Compared to the general example: 
      * `<ACTION>`  = `reads`
      * `<OBJECT>`  = `User`
      * `<ID>`      = `author`
      * `<COUNTER>` = `reads_got`
     
   So given a `reads` `<ACTION>`, the `reads_got` `<COUNTER>` of the `User` `<OBJECT>` with `<ID>` equals to `author`'s value, will be increase by one.
   
   **Notice** - in the config JSON, the value of `<ACTION>` (`reads`) is a hash, and the value of the `<OBJECT>` (`User`) is an array of hashes.
   
### Multiple Objects of The Same Yype
   now lets also count how many posts a user has read. 

   Meaning, that when a post gets read, we want to increase a counter for the author, like in previous example, and also increase a counter for the user who is now reading the post in order to know how many posts each user has read.

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
  
   The one who is reading the post now is also a `User` so we define it under the already existing `User` object.

   The user's id is defined in the query string params as the `user` parameter and for him we count `reads`.
   After a call to http://my-von-count.com/reads?author=1234&user=5678 our DB will look like:
   
   >User_1234: { reads_got: 2 }
   >
   >User_5678: { reads: 1 }
   
### Multiple Objects of Different Types
   We also want to know how many `reads` each `Post` received.

   We add the following configuration for `Post` object under the `reads` action, and we add a 'post' id to the query string parameters. 

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
   
   After a call to http://my-von-count.com/reads?author=1234&user=5678&post=888, thats what we'll have in the DB:
   
   >User_1234: { reads_got: 3 }
   >
   >User_5678: { reads: 2 }
   >
   >Post_888:  { reads: 1 }
   
   
### Object With Multiple Ids
   At [FTBpro](https://www.ftbpro.com) we are doing daily analytics. 

   For each `user` we want to know how many posts he read in each day.
   
   We'll define a "UserDaily" object. His id will be the user's id and the current date.

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
   
   Notice the `<ID>` of the `UserDaily` object is an **array**, and its composed of 4 parameters, so after a call to
   http://my-von-count.com/reads?user=5678, the DB will have the following data:
   >UserDaily_5678_28_11_2013: { reads: 1 }
   
   
   **WAIT A SECOND!** the query string contains only the `user` parameter, where does the other 3 parameters (`day`, `month`, `year`) come from?!? Read more about it on [Request Metadata Parameters Plugins](#request-metadata-parameters-plugins).
   

### Dynamic Count - Parameter as `<COUNTER>` Name
   We can use parameters to determine the `<COUNTER>` name. in that way we can dynamically determine what gets count.
   
   In this example, we count for an `author` how many reads he had from each country (every week).

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

   the data will be something like - 
   >UserWeeklyDemographics_5678_42_2013: { US: 5, UK: 8, FR: 1 }

  \*Its possible to use a parameter name that is passed in the request query string (e.g. `author`, `post`, etc...), and not only the Metadata Parameters!
  
  \* `<COUNTER>` names can be be more complex. lets say we have a `registered` parameter in the request query string, so in the config file we can define - `"count": "from_{country}_{registered}"`

   
### Existing Objects, Different Actions
   So far we've seen examples related to posts reads, but users can also comment on posts. 
   very similar to the `reads` action, we also want to count:
     * for each `author` - how many comments he received on his posts
     * for each `user` - how many comments he wrote
     * for each `post` - how many comments he received
   
   so on the `voncount.config` file, at the JSON's top level (**not** nested under the `reads` action!) we'll add -

   ```JSON
   {
     "reads": {
      .
      .
      .
     },
     
     "comments": {
       "User": [
         {
           "id": "user",
           "count": "comments"
         },
         {
           "id": "author",
           "count": "comments_got"
         }
       ],

       "Post": [
         {
           "id": "post",
           "count": "comments"
         }
       ]
      }
   }
   ```
   
   now we'll make a call to http://my-von-count.com/comments?author=1234&user=5678&post=888 and in the DB we'll have:
   >User_1234: { comments_got: 1 }
   >
   >User_5678: { comments: 1 }
   >
   >Post_888:  { comments: 1 }
   
### Ordered Sets (Leaderboard) - Save The Counters Data in Order
   In all previous examples the data saved in Redis was of type Hash. 

   Its possible to save the data in ZSet as well. in that way you can get data already ordered by the counters value. 
   
   This can be very usefull for leaderboards and such. 
   For example, we want to know the "top 3 posts" (posts that got the most reads) in each day - 
   
   ```JSON
   {
     "reads": {
      .
      .
      .
      "PostDaily": [
         {
           "type": "set",
           "id": [
             "day",
             "month",
             "year"
           ],
           "count": "post_{post}",
           "expire": 604800
         }
       ]
   ```
   You can see we defined a `type` equals to "set". you can also define `type` as "hash" which is the default option so you can just skip this definition like in previous examples.
   
   \* We are using the `post` id as part of the `<COUNTER>` name, similar to example #5.
   
   The data for this example will look like -
   
   >PostDaily_28_11_2013: {
   >
   >     post_888: 2,
   >
   >     post_53:  15,
   >
   >     post_932: 26,
   >
   >     ...
   >}
   
   The data is ordered, and you can retrieve it using Redis's `zrange` and `zrevrange` commands, and - for the sake of our example - get the "top 3 posts" without fetching the entire set and doing your own sort on the values, but simply by - `zrevrange PostDaily_28_11_2013 0 2`
   
   The downside of sets, as opposed to hashed, is that you cannot retreive a specific `<COUNTER>` value.

   Later when we'll talk about [retriving data](#retriving-data), we'll show how to retrive data through the server, and without accessing Redis directly.

### Advance: Custom Functions - Writing Your Own Logic
   the system enables you to go crazy and implement more complex logics for your counters. To do that, you'll need to get your hands a bit dirty, and write some Lua code.

   in this example we'll implement *conditional count*:
   
   when a new `post` is created, we report a `post_create` action - http://my-von-count.com/post_create?user=1234, and increase the `post_created` counter for the `user` who wrote the post - 
   ```JSON
   "post_create": {
     "User": [
       {
         "id": "user",
         "count": "post_created"
       }
     ]   
   ```
   
   Reminder - a `post` "belongs" to a `team`, and we want to know for each `team` how many `posts` it have,
   
   **BUT** we want to count only posts that have at least 200 words.
   
   so when reporting the `post_create` action, we'll add the `team` parameter to the query string, and lets also add another parameter - `long_post` that will get "true" or "false" as values.
   
   our call will look like - http://my-von-count.com/post_create?user=1234&team=10&long_post=true
   
   the config file - 
   ```JSON
   "post_create": {
     "User": [
       {
         "id": "user",
         "count": "post_created"
       }
     ],
     
     "TeamCounters": [
       {
         "id": "team",
         "custom_functions": [
           {
             "name": "conditionalCount",
             "args": [
               "{long_post}",
               "posts"
             ]
           }
         ]
       }
     ]     
   ```
   
   and now lets write the Lua code for this custom function in `lib/redis/voncount.lua`:
   ```lua
   ----------------- Custom Methods -------------------------
   
    function Base:conditionalCount(should_count, key)
      if should_count == "true" then
        self:count(key, 1)
      end
    end
   
   ```
   
   what do we have here:
      - `conditionalCount` is the name of our new custom function, and it must be equal to the "name" is the config.
      - our custom function received 2 arguments, which are defined by the "args" in the config:
         * `should_count` will receive the value of the `long_post` parameter provided in the query string.
         * `key` will always receive the same value - the string "posts"
      - `self:count(key, 1)` - is a call to a different function - `count` - which is the basic count functionality and is already defined in the `lib/redis/voncount.lua` file. (`self` is the current instance of the `Base` class that defines the `count` function and our new `conditionalCount` custom function)
      
   \* **Notice** that the `post_create` count for the `User` object is not effected, and it always gets count, even if the `long_post` parameter is "false".
  
   The data will look like - 
   >TeamCounters_7: { posts: 324 }
   
### Variable Count - Not Just Increase by 1
   In all previous examples we always increased the `<COUNTER>` by 1 with each call, but this doesn't have to be the case.

   The system lets you decide the increment number using the `change` definition in the config file.
   
   In example #8 we showed how we count for a `user` how many posts he created. when a post is deleted we want to decrease this counter. We'll define a `post_remove` action that will be resposible for this decrement:
   
   ```JSON
   "post_remove": {
      "User": [
        {
          "id": "user",
          "count": "post_created",
          "change": -1
        }
      ]
   }
   ```
   Notice we decrease the value of the "post_created" `<COUNTER>`
   
   So if in the DB we have:
   >User_1234: { post_created: 5 }
   Then after a call to http://my-von-count.com/post_remove?user=1234, our data will be:
   >User_1234: { post_created: 4 }
   
   \* `change` can have any integer value, not just 1 or -1!
   
## Expire - setting TTL on Redis data
  Those of you with a keen eye might have noticed that in examples #4 and #7 the configuration include an `expire` definition.
  
  You can put it on any `<OBJECT>` in the config, and it sets its TTL (time to live) in Redis. The value is in seconds (e.g. 1209600 = 2 weeks).
  
  This is usefull in order to keep the amount of data in the DB at a sane size, and also help keep it clean from old irrelevant data that we may never need again.
  
  The TTL is set on the first time the data is created in our Redis DB, and it is **not** getting extended when the data is updated!
  
  Take a look at example #4 again. Lets assume the DB is empty. 
  
  After a call to http://my-von-count.com/reads?user=5678, our DB will have, the following data - 
  >UserDaily_5678_28_11_2013: { reads: 1 }
  
  This data will have a TTL of 2 weeks. 
  
  If after 4 days we'll make another call to http://my-von-count.com/reads?user=5678, then our data will be
  >UserDaily_5678_28_11_2013: { reads: 2 }
  
  but its TTL will be equal to only the remaining 10 days!
  
  If we'll wait another 10 days, this data will be gone!
  

# Request Metadata Parameters Plugins

   Sometimes there is need that the key names will consist data that is not part of the request arguments, but is based on the request metadata. Currently, we support 2 types this cases: date_timeparamerters and country parameter.    
   The Request Metadata Parameters works as a plugin mechanisem. Enabling/disabling plugins can be done by adding/removing the plugin name in `lib/nginx/request_metadata_parameters_plugins/registered_plugins.lua'. Let's discuss the default plugins which come out of the box.
   
## DateTime Plugin
   
   | Parameter Name | Description                                                          |
   |----------------|----------------------------------------------------------------------|
   | *day*          | current day of the month                                             |
   | *yday*         | day index of the year (out of 365)                                   |
   | *week*         | week index of the year (out of 52). week start and end on Mondays.   |
   | *month*        | month index of the year (out of 12)                                  |
   | *year*         | in 4 digits format                                                   |

### Adding custom date_time paramaeters
  
  The plugin comes with the arguments that we think are needed. If you want to add your parameters just update `lib/nginx/request_metadata_parameters_plugins/date_time.lua' with the relevant time formation.
   
   ## Country Plugin
   
   This plugin is disabled by default.To enable id just uncomment 'country' in `lib/nginx/request_metadata_parameters_plugins/registered_plugins.lua' file. 
   
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

#Retriving Data

#Advanced

#Architecture

![Architecture](https://s3-us-west-2.amazonaws.com/action-counter-logs/cvc2.png)

Count-von-Count uses [OpenResty](http://openresty.org/) as a web server. It's basicaly a Nginx server, bundled with 3-rd party modules. One of them is [lua-nginx-module](https://github.com/chaoslawful/lua-nginx-module) which adds the ability to execute Lua scripts in the context of Nginx. Another useful module is [lua-resty-redis](https://github.com/agentzh/lua-resty-redis) which we use to comminicate with Redis, which is where we store the data.

The flow of a counting request is:
1. A client sends a request in the format of <count_von_count_server>/<action>?params. When the request arrives, Nginx triggers a lua script. After the script finishes, an empty 1X1 pixel is returned to the client.
2. This Lua scripts parse the query params from the request, adds addtional params using the Request Metadata Paramerts Plugins and calls Redis to evaluate a preloaded Lua script.
3. The redis script updates all the relevant keys , according to the von_count.config configuration file.
4. In case of a disaster, a recovery is available through a Log Player.

#Log Player

Count-von-count comes with a log player.It is very useful in cases of recovery after system failure or running on old logs with new logic. Its input is access log file (a log file where the Nginx logs each incoming request). It updates the Redis based on the voncount.config.

#Deploy using Ruby and [Capistrano](https://github.com/capistrano/capistrano)

   Edit `deploy.rb` file and set the correct deploy user and your servers ips in the `deploy` and `env_servers` variables.

   **for the first time** run `cap deploy:setup` to bootstrap the server.

   use `cap deploy` to deploy master branch to production.

   use `cap deploy -S env=qa -S branch=bigbird` if you want to deploy to a different environment and/or a different branch.

#Contributing

  1. Fork it
  2. Create your feature branch (git checkout -b my-new-feature)
  3. Commit your changes (git commit -am 'Added some feature')
  4. Push to the branch (git push origin my-new-feature)
  5. Create new Pull Request

# Contact Us

For any questions, suggestions or feedback, feel free to mail us at:

ron@ftbpro.com
shai@ftbpro.com

