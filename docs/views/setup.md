# Setup

To setup the project clone from bitbucket and change into the root
directory using your terminal.  Make you've installed *nodejs*, *npm*
and *bower*.

## Install server dependencies

First we have to setup all dependencies required for the server.  For
this use *npm*.

    $ npm install

## Install client dependencies

The next step is the installation of all the client dependencies:
*jQuery* etc.

    $ bower install

## Boot the project

For this step you need *docker* and *fig*.

    $ fig up
    Recreating webdesignio_redis_1...
    Recreating webdesignio_mongo_1...
    Recreating webdesignio_web_1...
    Attaching to webdesignio_redis_1, webdesignio_mongo_1, webdesignio_web_1
    mongo_1 | mongod --help for help and startup options
    mongo_1 | 2015-01-13T16:05:04.163+0000 [initandlisten] MongoDB starting : pid=1 port=27017 dbpath=/data/db 64-bit host=25ecefe72b49
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] db version v2.6.5
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] git version: e99d4fcb4279c0279796f237aa92fe3b64560bf6
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] build info: Linux build8.nj1.10gen.cc 2.6.32-431.3.1.el6.x86_64 #1 SMP Fri Jan 3 21:39:27 UTC 2014 x86_64 BOOST_LIB_VERSION=1_49
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] allocator: tcmalloc
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] options: {}
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] 
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] ** WARNING: Readahead for /data/db is set to 3072KB
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] **          We suggest setting it to 256KB (512 sectors) or less
    mongo_1 | 2015-01-13T16:05:04.166+0000 [initandlisten] **          http://dochub.mongodb.org/core/readahead
    mongo_1 | 2015-01-13T16:05:04.199+0000 [initandlisten] journal dir=/data/db/journal
    mongo_1 | 2015-01-13T16:05:04.200+0000 [initandlisten] recover : no journal files present, no recovery needed
    mongo_1 | 2015-01-13T16:05:04.302+0000 [initandlisten] waiting for connections on port 27017
    redis_1 | [1] 13 Jan 16:04:57.081 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
    redis_1 |                 _._                                                  
    redis_1 |            _.-``__ ''-._                                             
    redis_1 |       _.-``    `.  `_.  ''-._           Redis 2.8.13 (00000000/0) 64 bit
    redis_1 |   .-`` .-```.  ```\/    _.,_ ''-._                                   
    redis_1 |  (    '      ,       .-`  | `,    )     Running in stand alone mode
    redis_1 |  |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
    redis_1 |  |    `-._   `._    /     _.-'    |     PID: 1
    redis_1 |   `-._    `-._  `-./  _.-'    _.-'                                   
    redis_1 |  |`-._`-._    `-.__.-'    _.-'_.-'|                                  
    redis_1 |  |    `-._`-._        _.-'_.-'    |           http://redis.io        
    redis_1 |   `-._    `-._`-.__.-'_.-'    _.-'                                   
    redis_1 |  |`-._`-._    `-.__.-'    _.-'_.-'|                                  
    redis_1 |  |    `-._`-._        _.-'_.-'    |                                  
    redis_1 |   `-._    `-._`-.__.-'_.-'    _.-'                                   
    redis_1 |       `-._    `-.__.-'    _.-'                                       
    redis_1 |           `-._        _.-'                                           
    redis_1 |               `-.__.-'                                               
    redis_1 | 
    redis_1 | [1] 13 Jan 16:04:57.090 # Server started, Redis version 2.8.13
    redis_1 | [1] 13 Jan 16:04:57.090 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
    redis_1 | [1] 13 Jan 16:04:57.096 * DB loaded from disk: 0.006 seconds
    redis_1 | [1] 13 Jan 16:04:57.096 * The server is now ready to accept connections on port 6379
    web_1   | 
    web_1   | > webdesignio@0.0.0 start /usr/src/app
    web_1   | > NODE_PATH=. node-dev server.coffee
    web_1   | 
    web_1   | 13 Jan 16:05:11 - server listening

Open you're browser and navigate to
[http://localhost:3000](http://localhost:3000) and you should see the
landing page.  If you get `Failed to connect to database!` just give
the database server a little more time to finish its boot process.

Now you're ready to develop with *webdesignio*.  Go ahead to
[structure](structure) to learn more the concepts.
