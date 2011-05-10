Napalm
=========
Distributed Message Queueing System as a weekend project to learn eventmachine. Hopefully it turns into something more :)

You can:

 * make synchronous and asynchronous calls.
 * have workers can compute multiple tasks.
 * setup multiple workers to distribute the load.
 * pass arbitrary objects to workers.
 * have workers run on separate machines.
 * have workers act as clients (think map-reduce)
 * async callbacks
 
 In progress:

 * saves jobs that aren't completed, and starts jobs up if job server crashes.
 * allow worker to use async callbacks
