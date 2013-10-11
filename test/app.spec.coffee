assert = require 'assert'
stream = require 'stream'
http   = require 'http'
fs     = require 'fs'
os     = require 'os'

request = require 'request'
require('../')(request)

testFile = "#{__dirname}/test.jpg"

server = http.createServer (req, res) ->
    res.writeHead 200, { 'Content-Type': 'image/jpeg' }
    fs.createReadStream(testFile).pipe(res)

server.listen 8755
address = server.address()
testURL = "http://#{address.address}:#{address.port}/test.jpg"

# ----------------------------------------------------------------------------- #

filesMatch = (file) ->
    return (
        fs.statSync(testFile).size == fs.statSync(file.path).size &&
        fs.readFileSync(testFile).toString() == fs.readFileSync(file.path).toString()
    )

test '.temp method added to request', ->
    assert.ok(request.temp, '.temp should exist')
    assert.ok(typeof request.temp is 'function', '.temp is a function')

test 'saves file to tmp dir', (done) ->
    request.temp testURL, (err, res, body, file) ->
        assert.ifError(err)
        assert fs.existsSync file.path
        assert file.path.indexOf(os.tmpdir()) is 0
        assert filesMatch(file)
        done()

test 'accepts object argument', (done) ->
    request.temp { url: testURL }, (err, res, body, file) ->
        assert.ifError(err)
        assert filesMatch(file)
        done()


