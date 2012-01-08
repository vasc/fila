vows = require('vows')
assert = require('assert')

fila = require('../lib/fila')

vows.describe('fila').addBatch(
    'Any fila':
        topic: new fila()

        'has an empty task queue,': (f) ->
            assert.lengthOf f.tasks, 0
        'and an enqueue function': (f) ->
            assert.isFunction f.enqueue

    'A fila filled with synchronous functions':
        topic: () ->
            callback = this.callback
            f = new fila()
            results = []
            f.enqueue (cb) -> 
                results.push 1
                cb() 
            f.enqueue (cb) ->
                results.push 2
                cb()
            f.enqueue (cb) ->
                results.push 3
                callback null, results
            return
    

        'produces the correct results': (r) ->
            assert.include r, 1
            assert.include r, 2
            assert.include r, 3
                
        'in the correct order': (r) ->
            assert.deepEqual r, [1,2,3]

    'A fila filled with assynchronous functions':
        topic: () ->
            f = new fila()
            callback = this.callback
            results = []
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 1
                    cb()
                , 300 
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 2
                    cb()
                , 150
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 3
                    callback null, results
                , 1
            
            return

        'produces the correct results': (r) ->
            assert.include r, 1
            assert.include r, 2
            assert.include r, 3
        
        'in the correct order': (r) ->
            assert.deepEqual r, [1,2,3]
        
    'A fila with concurrent assynchronous functions when run':
        topic: () ->
            f = new fila(3)
            callback = this.callback
            results = []
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 1
                    cb()
                , 300 
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 2
                    cb()
                , 150
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 3
                    cb()
                , 1
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 4
                    callback null, results
                , 600 
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 5
                    cb()
                , 300
            f.enqueue (cb) -> 
                setTimeout () -> 
                    results.push 6
                    cb()
                ,1
            
            return

        'produces the correct results': (r) ->
            assert.include r, 1
            assert.include r, 2
            assert.include r, 3
            assert.include r, 4
            assert.include r, 5
            assert.include r, 6
        
        'in the expected order': (r) ->
            assert.deepEqual r, [3, 2, 1, 6, 5, 4]
            
                
).export(module)