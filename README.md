Napalm
=========
Distrubted Message Queueing System as a weekend project to learn eventmachine. Hopefully it turns into something more :)

You can:
  - make synchronous and asynchronous calls.
  - have workers can compute multiple tasks.
  - setup multiple workers to distrubute the load.
  - pass arbitrary objects to workers.
  - have workers run on seperate machines.

In progress:
  - saves jobs that aren't completed, and starts jobs up if job server crashes.
