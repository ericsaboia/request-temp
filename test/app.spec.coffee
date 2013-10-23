assert = require 'assert'
stream = require 'stream'
http   = require 'http'
fs     = require 'fs'
os     = require 'os'

request = require 'request'
tempRequest = require('../')(request)

testFile = "#{__dirname}/test.jpg"
testFileAsString = fs.readFileSync(testFile).toString()
testFileSize = fs.statSync(testFile).size

server = http.createServer (req, res) ->
    res.writeHead 200, { 'Content-Type': 'image/jpeg' }
    fs.createReadStream(testFile).pipe(res)

server.listen 8755
address = server.address()
testURL = "http://#{address.address}:#{address.port}/test.jpg"

# ----------------------------------------------------------------------------- #

assert.filesMatch = (file, cb) ->
    fs.stat file.path, (err, stat) ->
        assert.ifError(err)
        assert.equal testFileSize, stat.size
        fs.readFile file.path, (err, contents) ->
            assert.equal testFileAsString, contents
            cb()

test '.temp method added to request', ->
    assert.ok(request.temp, '.temp should exist')
    assert.ok(typeof request.temp is 'function', '.temp is a function')

test 'saves file to tmp dir', (done) ->
    request.temp testURL, (err, res, body, file) ->
        assert.ifError(err)
        assert fs.existsSync file.path
        assert file.path.indexOf(os.tmpdir()) is 0
        assert.filesMatch(file, done)

test 'return arguments match request.get', (done) ->
    request.temp testURL, (err, res, body, file) ->
        request.get testURL, (err2, res2, body2) ->
            assert.deepEqual(err, err2)
            assert.deepEqual(Object.keys(res), Object.keys(res2))
            assert.deepEqual(body, body2)
            done()

test 'arguments (object, callback)', (done) ->
    request.temp { url: testURL }, (err, res, body, file) ->
        assert.ifError(err)
        assert.filesMatch(file, done)

test 'arguments (url, object, callback)', (done) ->
    request.temp testURL, {}, (err, res, body, file) ->
        assert.ifError(err)
        assert.filesMatch(file, done)

test 'throws error with empty first argument', (done) ->
    for arg in [null, undefined, 0]
        try request.temp(arg); catch err
        try request.get(arg); catch err2
        assert.deepEqual(err, err2)

    request.temp '', (err) ->
        request.get '', (err2) ->
            assert.deepEqual(err, err2)
            done()

test 'returns error with non-existent path', (done) ->
    request.temp 'http://127.0.0.1:37495/MMgLmdeeO.xpt', (err, res, body, file) ->
        assert(err)
        assert.equal(err.code, 'ECONNREFUSED')
        request.get 'http://127.0.0.1:37495/MMgLmdeeO.xpt', (err2) ->
            assert(err2)
            assert.deepEqual(err, err2)
            assert.equal(err2.code, 'ECONNREFUSED')
            done()

test 'can be used as a stand-alone function', (done) ->
    tempRequest { url: testURL }, (err, res, body, file) ->
        assert.ifError(err)
        assert.filesMatch(file, done)
