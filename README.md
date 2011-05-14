Napalm
=========
Distributed Message Queueing System as a weekend project to learn eventmachine. Hopefully it turns into something more :)

You can:

 * make synchronous and asynchronous calls.
 * have workers compute multiple tasks.
 * setup multiple workers to distribute the load.
 * pass arbitrary objects to workers.
 * have workers run on separate machines.
 * have workers act as clients (think map-reduce)
 * async callbacks

In Progress:

 * Restart workers when they disconnect from Job Server
 * Have ability to specify which server and port to listen on(for both job and worker)


###Run Job Server
    napalm

###Create Worker
    #worker.rb
    require 'napalm'
    
    class MyWorker < Napalm::Worker
      worker_methods :add_me

      def add_me(x, y)
        x+y
      end

      def some_private_function
        "hi"
      end
    end

    MyWorker.do_work

###Run Worker
     ruby worker.rb

###Create Client
    require 'napalm'
    
    #async calls
    Napalm::Client.start do |client|
      client.do_async(:add_me, 3, 5){|result| puts result}
      client.do_async(:add_me, 100, 1){|result| puts result}
    end

    #sync calls
    result = Napalm::Client.do(:add_me, 3, 5)

