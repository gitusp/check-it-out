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
	}
}