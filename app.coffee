cluster = require 'cluster'
os = require 'os'
Master = require './lib/cluster'

if cluster.isMaster
  master = new Master os.cpus().length
  master.on 'master:spawn', () ->
    console.log 'master spawned'
    # master code

  master.on 'worker:spawn', (worker) ->
    console.log "worker spawned, pid: #{ worker.process.pid }"

  master.on 'worker:exit', (worker) ->
    console.log "worker exited, pid: #{ worker.process.pid }"

  master.on 'master:exit', () ->
    console.log 'master exiting...'

  master.start()
else
  # worker code
  # worker will be respawned on throw
  # throw 'teste'
