vows = require('vows')
assert = require('assert')

fila = require('../lib/fila')

vows.describe('fila').addBatch(
    'Any fila':
        topic: new fila.fila()

        'has an empty task queue,': (f) ->
            assert.lengthOf f.tasks, 0
        'a run function': (f) ->
            assert.isFunction f.run
        'a push function': (f) ->
            assert.isFunction f.push
        'and a next function': (f) ->
            assert.isFunction f.next

    'An empty fila':
        topic: new fila.fila()

        'when run':
            topic: (f) ->
                f.run (r) =>
                    this.callback null, r
                return

            'produces no results': (f) ->
                assert.lengthOf f, 0
                

    'A fila filled with synchronous functions':
        topic: () ->
            f = new fila.fila()
            f.push (next) -> next 1 
            f.push (next) -> next 2
            f.push (next) -> next 3
            f
    
        'holds them': (f) ->
            assert.lengthOf f.tasks, 3
            f.tasks[0] (r) -> assert.equal r, 1 
            f.tasks[1] (r) -> assert.equal r, 2
            f.tasks[2] (r) -> assert.equal r, 3
    
        'when run':
            topic: (f) ->
                f.run (r) =>
                    this.callback null, r
                return

            'produces the correct results': (r) ->
                assert.include r, 1
                assert.include r, 2
                assert.include r, 3
            
            'in the correct order': (r) ->
                assert.deepEqual r, [1,2,3]

    'A fila filled with assynchronous functions when run':
        topic: () ->
            f = new fila.fila()
            f.push (next) -> 
                setTimeout () -> 
                    next 1
                , 300 
            f.push (next) -> 
                setTimeout () -> 
                    next 2
                , 150
            f.push (next) -> 
                setTimeout () -> 
                    next 3
                , 1
            
            f.run (r) =>
                this.callback null, r
            return

        'produces the correct results': (r) ->
            assert.include r, 1
            assert.include r, 2
            assert.include r, 3
        
        'in the correct order': (r) ->
            assert.deepEqual r, [1,2,3]
        
).export(module)