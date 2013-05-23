var fs = require('fs');

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
		console.log(req.param('width'));
		// urlとかも返すのか
		res.json({status: 'success'});
	},
	capture: function (req, res) {
		var json = {
			image: 'hoge',
			width: 500,
			height: 500
		};
		res.view('pages/capture', {dna: JSON.stringify(json)});
	},
}