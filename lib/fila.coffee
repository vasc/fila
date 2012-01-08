events = require 'events'

class Fila
	constructor: (concurrency) ->
		
		@slots = if concurrency == undefined then 1 else concurrency
		@ee = new events.EventEmitter()
		@tasks = []
			
		@ee.on 'over', () =>
			@slots+=1
			@next()			

	enqueue: (f) ->
		this.tasks.push f
		@next()

	next: () ->
		ee = this.ee
		if this.tasks.length > 0 and this.slots > 0
			this.slots-=1
			t = this.tasks.shift()
			t () => ee.emit 'over'

	
module.exports = Fila
