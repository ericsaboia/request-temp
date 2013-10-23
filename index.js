var path = require('path')
  , url  = require('url')
  , os   = require('os')
  , fs   = require('fs')
  , request

function tempFile (_url) {
    var name = path.basename(url.parse(_url).pathname) || Math.floor(Math.random() * 1e20).toString(16)
      , tmpName = [Date.now(), process.pid, name].join('-')

    return {
        name: name
      , path: path.join(os.tmpdir(), tmpName)
    }
}

function tempRequest (_url) {
    var args = Array.prototype.slice.call(arguments, 0)
      , _url = (typeof _url === 'string') ? _url : _url.uri || _url.url
      , file = tempFile(_url)
      , cb   = args[args.length - 1]
      , tmp  = fs.createWriteStream(file.path)

    if (typeof cb === 'function') {
        args[args.length - 1] = function (err, res, body) {
            cb(err, res, body, file)
        }
    }

    return request.get.apply(request, args).pipe(tmp)
}

module.exports = function (_request) {
    request = _request
    return request.temp = tempRequest
}
