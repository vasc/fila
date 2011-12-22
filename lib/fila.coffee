events = require 'events'

exports.fila = () ->
			this.self = this
			this.ee = new events.EventEmitter()
			this.tasks = []
			this.results = []
			return this

exports.fila.prototype = 
			run: (end) ->
				this.end = end
				this.ee.on 'next', (result) =>
					this.results.push result
					this.next()
				this.next()

			push: (f) ->
				this.tasks.push f

			next: () ->
				if this.tasks.length > 0
					t = this.tasks.shift()
					t (result) => this.ee.emit 'next', result
				else 
					this.end(this.results) unless this.end == undefined
		

						
