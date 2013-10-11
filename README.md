request.temp
============

Request plugin to save files to local tmp dir.

### Usage

    var request = require('request')

    // adds the request.temp() method
    request('request-temp')(request)

    request.temp('http://somesite.com/image.jpg', function (err, res, body, file) {
        console.log(file.path)
        console.log(file.name)
    })

Takes the same arguments as other request methods: `request.temp(url, options, callback)`.

### Examples

    // Using mongoose-attachments
    request.temp('http://path.to.image/image.png', function (err, res, body, file) {
        // does imagemagick transforms, resizes, uploads to s3
        model.attach('picture', file, function (err) {
            // save result
            model.save()
        })
    })

