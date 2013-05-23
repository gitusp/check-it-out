fs = require("fs")
client = require("capture/client")
module.exports =
	upload: (req, res) ->
		type = req.files.image.type
		fs.readFile req.files.image.path, (err, data) ->
			unless err
				# TODO: fallback
				# res.json({'hoge': 'piyo'});
				result = "data:#{type};base64," + data.toString("base64")
				res.view "pages/upload", image: "\"#{result}\""

	share: (req, res) ->
		client.run req.param("dna"), (data) ->
			console.log data
	
	# キャプチャ用の内部ページ
	capture: (req, res) ->
		res.view "pages/capture",
			dna: req.param("dna")
