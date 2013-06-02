// Generated by CoffeeScript 1.6.2
(function() {
  var client, createHash, crypto, dateformat, fs, sv, uuid;

  fs = require('fs');

  client = require('capture/client');

  sv = require('local_shared_values');

  crypto = require('crypto');

  uuid = require('uuid');

  dateformat = require('dateformat');

  createHash = function(callback) {
    var htry, randobet;

    randobet = function(n) {
      var a, i, s;

      a = ('abcdefghijklmnopqrstuvwxyz' + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + '0123456789').split('');
      s = (function() {
        var _i, _results;

        _results = [];
        for (i = _i = 0; 0 <= n ? _i <= n : _i >= n; i = 0 <= n ? ++_i : --_i) {
          _results.push(a[Math.random() * a.length | 0]);
        }
        return _results;
      })();
      return s.join('');
    };
    htry = function() {
      var hash;

      hash = randobet(12);
      return Image.find({
        hash: hash
      }).done(function(err, result) {
        if (result == null) {
          return callback(hash);
        } else {
          return htry();
        }
      });
    };
    return htry();
  };

  module.exports = {
    upload: function(req, res) {
      var type;

      if (/image\/p?jpe?g/.test(req.files.image.type)) {
        type = 'jpg';
      } else if (/image\/(x-)?png/.test(req.files.image.type)) {
        type = 'png';
      } else if (/image\/gif/.test(req.files.image.type)) {
        type = 'gif';
      } else {
        type = 'unk';
      }
      if (type !== 'unk') {
        return fs.readFile(req.files.image.path, function(err, data) {
          if (!err) {
            return createHash(function(hash) {
              return Image.create({
                hash: hash,
                image: data,
                type: type,
                tmp: true
              }).done(function(err, img) {
                if (!err) {
                  return res.view("pages/upload", {
                    uploadStatus: 'success',
                    image: "\"/s/" + hash + "\""
                  });
                } else {
                  return res.view("pages/upload", {
                    uploadStatus: 'exception'
                  });
                }
              });
            });
          } else {
            return res.view("pages/upload", {
              uploadStatus: 'exception'
            });
          }
        });
      } else {
        return res.view("pages/upload", {
          uploadStatus: 'unsupportedimage'
        });
      }
    },
    share: function(req, res) {
      var dna, runClient, tmpHash;

      dna = req.param('dna');
      dna.port = sv.port;
      runClient = function(dna) {
        var myClient;

        myClient = new client(dna);
        return myClient.run(function(data64) {
          var data;

          if (data64 != null) {
            data = new Buffer(data64.toString(), 'base64');
            return createHash(function(hash) {
              return Image.create({
                hash: hash,
                image: data,
                type: 'png',
                tmp: false
              }).done(function(err, img) {
                var expire, future, token;

                if (!err) {
                  future = new Date((new Date).getTime() + 60 * 60 * 24 * 30 * 1000);
                  expire = dateformat(future, "yyyy/mm/dd HH:MM:ss");
                  token = uuid.v4();
                  req.session.keyToken = req.session.keyToken || {};
                  req.session.keyToken[token] = img.id;
                  return res.json({
                    status: 'success',
                    url: "/s/" + hash,
                    token: token,
                    expire: expire
                  });
                } else {
                  return res.json({
                    status: 'failure'
                  });
                }
              });
            });
          } else {
            return res.json({
              status: 'failure'
            });
          }
        });
      };
      if (dna.nonBase64) {
        tmpHash = dna.image.split('/').pop();
        return Image.find({
          hash: tmpHash
        }).done(function(err, img) {
          if (!err && (img != null)) {
            dna.image = ("data:" + img.type + ";base64,") + img.image.toString('base64');
            dna.nonBase64 = null;
            return runClient(dna);
          } else {
            return res.json({
              status: 'failure'
            });
          }
        });
      } else {
        return runClient(dna);
      }
    },
    show: function(req, res) {
      return Image.find({
        hash: req.param('hash')
      }).done(function(err, img) {
        if (!err && (img != null)) {
          res.setHeader('Content-Type', "image/" + img.type);
          res.setHeader('Expires', new Date(Date.now() + 60 * 60 * 24 * 1000).toUTCString());
          return res.end(img.image);
        } else {
          return res.view('404');
        }
      });
    },
    key: function(req, res) {
      var hash, imageId, key, shasum, token;

      key = req.param('key', '');
      token = req.param('token', '');
      imageId = req.session.keyToken[token];
      if (imageId == null) {
        return res.json({
          status: 'exception'
        });
      }
      hash = '';
      if (key) {
        shasum = crypto.createHash('sha1');
        shasum.update(key);
        hash = shasum.digest('hex');
      }
      return Image.update(imageId, {
        key: hash
      }, function(err, img) {
        if (!err) {
          return res.json({
            status: 'success'
          });
        } else {
          return res.json({
            status: 'exception'
          });
        }
      });
    },
    confirm: function(req, res) {
      var hash, key, shasum;

      key = req.param('key', '');
      hash = req.param('hash', '');
      if (!key) {
        return res.view('404');
      }
      shasum = crypto.createHash('sha1');
      shasum.update(key);
      key = shasum.digest('hex');
      return Image.find({
        hash: hash,
        key: key
      }).done(function(err, img) {
        var token;

        if (!err && (img != null)) {
          token = uuid.v4();
          req.session.deleteToken = req.session.deleteToken || {};
          req.session.deleteToken[token] = img.id;
          return res.view('pages/delete', {
            mode: 'form',
            token: token,
            imageSource: "/s/" + hash
          });
        } else {
          return res.view('404');
        }
      });
    },
    "delete": function(req, res) {
      var imageId, token;

      token = req.param('token', '');
      imageId = req.session.deleteToken[token];
      if (imageId == null) {
        return res.view('pages/delete', {
          mode: 'done',
          error: true
        });
      }
      return Image.destroy(imageId, function(err, img) {
        return res.view('pages/delete', {
          mode: 'done',
          error: err
        });
      });
    }
  };

}).call(this);
