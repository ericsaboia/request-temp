var path    = require('path')
  , url     = require('url')
  , os      = require('os')
  , fs      = require('fs')
  , request

function initParams (uri, options, callback) {
    if ((typeof options === 'function') && !callback){
        callback = options
    }
    if (options && typeof options === 'object') {
        options.uri = uri
    } else if (typeof uri === 'string') {
        options = {uri:uri}
    } else {
        options = uri
        uri = options.uri
    }
    return { uri: uri, options: options, callback: callback }
}

function tempFile (_url) {
    var name = path.basename(url.parse(_url).pathname) || Math.floor(Math.random() * 1e20).toString(16)
      , tmpName = [Date.now(), process.pid, name].join('-')

    return {
        name: name
      , path: path.join(os.tmpdir(), tmpName)
    }
}

function tempRequest (_url, options, callback) {
    var params   = initParams(_url, options, callback)
      , options  = params.options
      , callback = params.callback
      , file     = tempFile(options.uri || options.url)
      , tmp      = fs.createWriteStream(file.path)

    function done (err, res, body) {
        if (res.statusCode >= 300) {
            return callback(new Error("Request failed (" + res.statusCode + ")"))
        }
        callback(err, res, body, file)
    }

    return request.get(options, done).pipe(tmp)
}

module.exports = function (_request) {
    request = _request
    request.temp = tempRequest
    return request
}
