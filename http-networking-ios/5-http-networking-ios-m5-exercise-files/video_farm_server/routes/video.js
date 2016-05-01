var Busboy = require('busboy');
var uuid = require('node-uuid');
var path = require('path');
var fs = require('fs');
var util = require('util');
var exec = require('child_process').exec;

var Datastore = require('nedb');
var VideosDB = new Datastore({
  filename: path.join(path.dirname(__filename), '..', 'videos.db'),
  autoload: true
});

VideosDB.ensureIndex({ fieldName: 'publicID', unique: true }, function (err) {
  if (err) {
    console.warn("Unable to create index for 'publicID' property: " + err);
  }
});

var makeURL = function(req, path) {
  return 'http://' + req.get('host') + path;
}

var cleanVideo = function(doc, req) {
  return {
    id: doc.publicID,
    title: doc.title,
    description: doc.description,
    url: makeURL(req, '/videos/' + doc.publicID),
    image: makeURL(req, '/videos/' + doc.publicID + '/thumbnail.png'),
    movie: makeURL(req, '/videos/' + doc.publicID + '/movie.mov'),
    duration: doc.duration,
    created: doc.created
  };
}

var getVideoDuration = function(videoID, callback) {
  var videoFile = path.join(path.dirname(__filename),
                            '..',
                            'public',
                            'videos',
                            videoID,
                            'movie.mov');

  exec('/usr/bin/afinfo ' + videoFile, function(error, stdout, stderr) {
    if (error) {
      callback(null, error);
    }
    else {
      var lines = stdout.split("\n");
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var matches = line.match(/^estimated duration: (\d+\.?\d*)/);
        if (matches) {
          callback(parseFloat(matches[1]), null);
          return;
        }
      };

      callback(null, null);
    }
  });
};

/**
 * GET /videos
 */
exports.list = function(req, res) {
  VideosDB.find({}).sort({ created: -1 }).exec(function(err, docs) {
    if (docs) {
      var videos = docs.map(function(e) {
        return cleanVideo(e, req);
      });

      res.format({
        json: function() {
          res.json(videos);
        },
        html: function() {
          res.render('videos', { videos: videos, timeago: require('timeago-words') });
        }
      });
    }
    else {
      res.format({
        json: function() {
          res.json(500, { error: err });
        },
        html: function() {
          res.write(500, err);
        }
      });
    }
  });
};

/**
 * GET /videos/:video_id
 */
exports.get = function(req, res) {
  var videoID = req.params.video_id;
  VideosDB.find({ publicID: videoID}, function(err, docs) {
    if (docs) {
      var video = cleanVideo(docs[0], req);
      res.format({
        json: function() {
          res.json(video)
        },
        html: function() {
          res.render('video', { video: video, timeago: require('timeago-words') });
        }
      });
    }
    else {
      res.format({
        json: function() {
          res.json(500, { error: err });
        },
        html: function() {
          res.write(500, err);
        }
      })
    }
  });
};

/**
 * POST /videos
 */
exports.add = function(req, res) {
  var busboy = new Busboy({ headers: req.headers });
  var id = uuid.v1();
  var destination = path.join(path.dirname(__filename),
                              '..',
                              'public',
                              'videos',
                              id);

  if (! fs.existsSync(destination)) {
    fs.mkdirSync(destination);
  };

  var fileWritten = false;

  busboy.on('file', function(fieldname, stream, filename, encoding, mimetype) {
    if (fieldname === 'thumbnail') {
      if (mimetype === 'image/png') {
        var imagePath = path.join(destination, "thumbnail.png");
        stream.pipe(fs.createWriteStream(imagePath));
        fileWritten = true;
      }
      else if (mimetype === 'image/jpeg') {
        var imagePath = path.join(destination, "thumbnail.jpeg");
        stream.pipe(fs.createWriteStream(imagePath));
        fileWritten = true;
      }
      else {
        stream.resume();
        res.set('Content-Type', 'text/plain');
        res.send(415, "Invalid type: " + mimetype + ". Supported image types include: image/png");
      }
    }
    else {
      stream.resume();  // ignore it
    }
  });

  var video = { publicID: id, created: new Date() };

  busboy.on('field', function(fieldname, value, fieldnameTruncated, valueTruncated) {
    if (fieldname === 'title') {
      video.title = value;
    }
    else if (fieldname === 'description') {
      video.description = value;
    }
    else {
      console.warn("Unknown field: " + fieldname);
    }
  });

  busboy.on('finish', function() {
    if (fileWritten) {
      VideosDB.insert(video, function(err, newDoc) {
        if (err === null) {
          res.writeHead(303, { Connection: 'close', Location: '/videos/' + id });
          res.end();
        }
      });
    }
    else {
      res.set('Content-Type', 'text/plain');
      res.send(400, 'Thumbnail image was not written');
    }
  });

  req.pipe(busboy);
};

/**
 * PUT /videos/:video_id/movie
 */
exports.uploadMovie = function(req, res) {
  var videoDir = path.join(path.dirname(__filename),
                           '..',
                           'public',
                           'videos',
                           req.params.video_id);

  if (fs.existsSync(videoDir)) {
    if (req.is('movie/quicktime') ||
        req.is('movie/mpeg') ||
        req.is('movie/mp4')) {

      var moviePath = path.join(videoDir, 'movie.mov');
      req.pipe(fs.createWriteStream(moviePath));
      req.on('end', function() {
        getVideoDuration(req.params.video_id, function(duration, err) {
          if (duration) {
            VideosDB.update({ publicID: req.params.video_id },
                            { $set: { duration: duration } },
                            {},
                            function (err, numReplaced, newDoc) {
                              res.writeHead(201);
                              res.end();
                              if (err) {
                                console.warn("Unable to update " + req.params.video_id + ": " + err);
                              };
                            });
          }
          else {
            res.writeHead(201);
            res.end();
          }
        });
      });
    }
    else {
      res.set('Content-Type', 'text/plain');
      res.send(415, 'Invalid MIME type: ' +
               req.get('Content-Type') +
               '. Valid types include movie/quicktime, movie/mpeg and movie/mp4');
    }
  }
  else {
    res.writeHead(404);
    res.end();
  }
}

/**
 * DELETE /videos/:video_id
 */
exports.delete = function(req, res) {
  var videoID = req.params.video_id;
  VideosDB.remove({ publicID: videoID }, {}, function(err, numRemoved) {
    if (err) {
      res.format({
        json: function() {
          res.json(500, { error: err });
        },
        html: function() {
          res.send(500, err);
        }
      });
    }
    else {
      res.format({
        json: function() {
          res.json(200, {});
        },
        html: function() {
          res.redirect('/videos');
        }
      });
    }
  });
}