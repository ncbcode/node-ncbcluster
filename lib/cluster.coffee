cluster = require 'cluster'
death = require 'death'
EventEmitter = require 'events'
os = require 'os'

class Master extends EventEmitter
  constructor: (qtyWorkers) ->
    @qtyWorkers = qtyWorkers || os.cpus().length
    @workers = []
    @stopped = true

    that = @

    death (signal, err) ->
      that.stop signal, err

  start: ->
    @stopped = false
    @spawn() for cpu in [1..@qtyWorkers]
    @emit 'master:spawn', @

  stop: (signal = 'SIGINT', err = null) ->
    @stopped = true
    @emit 'master:exit', @

    workers = @workers.splice()
    worker.kill() for worker in workers

    that = @

    interval = setInterval ->
      if that.workers.length is 0
        clearInterval interval
        process.exit 0
    , 100

  spawn: ->
    that = @

    worker = cluster.fork()
    worker.on 'exit', ->
      that.emit 'worker:exit', worker

      if that.stopped
        that.remove worker
      else
        that.respawn worker

    @workers.push worker
    @emit 'worker:spawn', worker

  remove: (worker) ->
    index = @workers.indexOf worker
    @workers.splice index, 1 if index isnt -1

  respawn: (worker) ->
    @remove(worker)
    @spawn()

module.exports = Master
