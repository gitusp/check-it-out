var fs = require('fs'),
	client = require('capture/client');

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
		client.run(req.param('dna'), function (data) {
			console.log(data);
		});
	},

	// キャプチャ用の内部ページ
	capture: function (req, res) {
		res.view('pages/capture', {dna: req.param('dna')});
	},
}