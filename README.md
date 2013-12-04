**General notes from Udi**
1. There is absolutely no introduction as to what this project does at all. It's definitely not trivial, so it's completely mandatory. It's more important than setup notes... What's special about counting here?  You can give a few short examples to begin with, to get people interested...
2. I think you should pay more attention to correct capitalization in beginnings of sentences. Makes things much easier to read. Don't blame me if I didn't do the same in my comments ;)
3. I generally didn't comment on grammar mistakes (I did found some). I think we should do proofing after the text is more-or-less finalized? Your thoughts?


Count Von Count
=================
![alt tag](http://1.bp.blogspot.com/_zCGbA5Pv0PI/TGj5YnGEDDI/AAAAAAAADD8/ipYKIgc7Jg0/s400/CountVonCount.jpg)

**__NOTICE - if you don't use the default folders as in the instructions, you'll need to edit and change `deploy.rb`, `setup.sh` and  `reload.sh`__**

Setting up a server (Ubuntu 13) 
---------------------------------
*Any reason this should be Ubuntu 13? (you mean 13.04? 13.10?). You can just say which version you tested on, and that it should work on others. Won't it work on a Mac, for development, just the same?*
1. install redis-server using apt-get install redis-server *Udi: no need to tell them how to install redis. link to redis project and let the have fun*
2. follow download and install direction on http://openresty.org/#Installation. recommended to use default settings and directory structure! *Again, I would say, "Install OpenResty. You should use the default settings."*
3. install git (sudo apt-get install git) *They know how to install git ;)*
4. add "include /usr/local/openresty/nginx/conf/include/*;" to openresty's nginx.conf, under the 'http' section (by default its in /usr/local/openresty/nginx/conf)
5. add set worker_rlimit_nofile 30000 in nginx.conf *Maybe you should show a syntax-higlighted example of nginx.conf with the needed changes in the last 2 steps*


Deployment
-----------------
### Using Ruby
You can use the provided Capistrano deployment.
Edit deploy.rb file and set the correct deploy user and your servers ips in the `deploy` and `env_servers` variables.

**for the first time** run `cap deploy:setup` to bootstrap the server.

use `cap deploy` to deploy master branch to production.

use `cap deploy -S env=qa -S branch=bigbird` if you want to deploy to a different environment and/or a different branch.


### Using shell scripts 
SSH into your count-von-count server.

**for the first time**
  * clone the git repository into your folder of choice (recommended to use our default - /home/deploy/count-von-count/current)
  * run `sudo ./lib/scripts/setup.sh`
 
next time after you update the code, SSH to your count-von-count machine, cd to the repository folder, pull the latest code, and then run `sudo ./lib/scripts/reload.sh`

*I'm not sure I understand - you mean you can do remote deployment using Capistrano or local deployment with shell script? If so I would give it such titles - "remote deployment" / "local deployment", and explain why you may choose one over the other...*


************************************************************************
************************************************************************

Counting - Its easy as 1,2,3
------------------------------
to configure what gets count and how, simply edit the `config/voncount.config` file.
the file is written in standart JSON notation.
for most use-cases you won't even need to write code!

We'll show here some examples that covers all the different options the system support. most of them are real life examples taken from our production environment. but first lets describe our domain to get in context - 

At [FTBpro](https://www.ftbpro.com) we have `posts`, `users`, `leagues`, and `teams`. 
each `post` is written by a `user` who is the author, and the post "belongs" to several `teams` and `leagues`.


1. ###simple count - post read
   ~~~
{
  "reads": {
    "User": [
      {
        "id": "user",
        "count": "reads"
      },
   ~~~

   the top most level of the configuration JSON keys is the action type that we want to count - `reads`.
   
   `User` is the object for which we want to count the `reads` action.
   
   `id` is the object (e.g. user's) id, and it should be defined in the query string parameters.
   
   `count` is what we count/increase.

   so, with the above configuration, if we make a call to http://my-von-count.com/reads?user=1234 then in the DB we'll have a key `User_1234` with value ``` { reads: 1 } ```
   
   **Notice** - the value of the action `reads` is a hash, and the value of the object `user` is an array of hashes.
   
2. ###simple count - multiple objects of the same type
   ~~~
{
  "reads": {
    "User": [
      {
        "id": "user",
        "count": "reads"
      },
      {
        "id": "author",
        "count": "reads_got"
      }
    ],
   ~~~
   
   whenever a post get reads, we also want to increase the number of reads the author of the post got.
   the author is also a `User` so we define it under the already existing `User` object.

   the author's id is defined in the query string params as `author` and for him we count `reads_got`,
   so after a call to http://my-von-count.com/reads?user=1234&author=5678 our DB will look like:
   
   >User_1234: { reads: 2 }
   >
   >User_5678: { reads_got: 1 }
   
3. ###simple count - multiple objects of different types
   ~~~
   {
  "reads": {
    "User": [
      {
        "id": "user",
        "count": "reads"
      },
      {
        "id": "author",
        "count": "reads_got"
      }
    ],
    "Post": [
      {
        "id": "post",
        "count": "reads"
      }
    ],
   ~~~
   
   We also want to know how many `reads` each `Post` received, so we add the above configuration for `Post` object under the `reads` action, and we add a 'post' id to the query string parameters. 
   
   After a call to http://my-von-count.com/reads?user=1234&author=5678&post=888, thats what we'll have in the DB:
   
   >User_1234: { reads: 2 }
   >
   >User_5678: { reads_got: 1 }
   >
   >Post_888:  { reads: 1 }
   
   
4. ###simple count - object with multiple IDs
   ~~~
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
   ~~~
   
   At [FTBpro](https://www.ftbpro.com) we are doing daily analytics, so for each `user` we want to know how many posts he read in each day.
   
   The 'ID' of the `UserDaily` object is an **array**, and is composed of 4 parameters, so after a call to
   http://my-von-count.com/reads?user=1234, the DB will have the following key-value 
   >UserDaily_1234_28_11_2013: { reads: 1 }
   
   
   **WAIT A SECOND!** the query string contains only the `user` parameter, where are the other 3 parameters come from?!?
   

   Built-In System Parameters
   ---------------------------
   The following parameters are provided by the system, out-of-the-box, and you can use them for objects IDs or for custom function parameters (will be described later)

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
