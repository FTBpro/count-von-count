**General notes from Udi**
1. There is absolutely no introduction as to what this project does at all. It's definitely not trivial, so it's completely mandatory. It's more important than setup notes... What's special about counting here?  You can give a few short examples to begin with, to get people interested...  
2. I think you should pay more attention to correct capitalization in beginnings of sentences. Makes things much easier to read. Don't blame me if I didn't do the same in my comments ;)  
3. I generally didn't comment on grammar mistakes (I did found some). I think we should do proofing after the text is more-or-less finalized? Your thoughts?


Count Von Count
=================
![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

**__NOTICE - if you don't use the default folders as in the instructions, you'll need to edit and change `deploy.rb`, `setup.sh` and  `reload.sh`__**

Setting up a server
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
to configure what gets count and how, simply edit the `config/voncount.config` file.
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
   
   
   **WAIT A SECOND!** the query string contains only the `user` parameter, where does the other 3 parameters (`day`, `month`, `year`) come from?!?
   

   Built-In System Parameters
   ---------------------------
   The following parameters are provided by the system, out-of-the-box, and you can use them for objects `<ID>`, (example #4), for `<COUNTER>` values (example #5), and custom function parameters (examples #7)

   | Parameter Name | Description                                                          |
   |----------------|----------------------------------------------------------------------|
   | *action*       | name of the action you are counting, e.g. `reads` in above examples. |
   | *day*          | current day of the month                                             |
   | *yday*         | day index of the year (out of 365)                                   |
   | *week*         | week index of the year (out of 52). week start and end on Mondays.   |
   | *month*        | month index of the year (out of 12)                                  |
   | *year*         | in 4 digits format                                                   |
   | *country*      | ONLY IF GEOIP PLUGIN IS INSTALLED - 2-letters country code according to the IP from which the call was made. |

   






Pitfalls & Gotcha
-------------------
(missing params in query string)

GeoIP Plugin
-------------
6) update init.lua with the location of the GeoIP.dat
