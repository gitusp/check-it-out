var fs = require('fs'),
	childProcess = require('child_process'),
	path = require('path'),
	phantomjs = require('phantomjs');

module.exports = {
	upload: function (req, res) {
		var type = req.files.image.type;
		fs.readFile(req.files.image.path, function (err, data) {
			if (err) {
				// TODO: fallback
				// res.json({'hoge': 'piyo'});
			} else {
				var result = 'data:' + type + ';base64,' + data.toString('base64');
				res.view('pages/upload', {image: '"' + result + '"'});
			}
		});
	},
	share: function (req, res) {
		// NOTE: node_modulesにもってく？
		var args = [
			path.join(__dirname, 'bridge.js'),
			__dirname,
			this._bank,
			JSON.stringify(this._info),
			JSON.stringify(this._cookies),
		];

		// ここでパス決めちゃって、それ経由でやり取りでもいい

		
		childProcess.execFile(phantomjs.path, args, function(err, stdout, stderr) {
			// stdout がバイナリでもいいのかな
			// urlとかも返すのか
			res.json({status: 'success'});
		});
	},

	// キャプチャ用の内部ページ
	capture: function (req, res) {
		res.view('pages/capture', {dna: req.param('dna')});
	},
}