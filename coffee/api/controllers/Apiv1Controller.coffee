fs = require("fs")
client = require("capture/client")

module.exports =
	# init by upload
	upload: (req, res) ->
		type = req.files.image.type
		fs.readFile req.files.image.path, (err, data) ->
			unless err
				result = "data:#{type};base64," + data.toString("base64")
				res.view "pages/upload", image: "\"#{result}\""
			else
				# TODO: fallback

	# end edit
	share: (req, res) ->
		myClient = new client req.param("dna")
		myClient.run (data) ->
			console.log data.toString()
	
	# キャプチャ用の内部ページ
	# NOTE: 結局何もしてないので実はこのメソッドいらない
	capture: (req, res) ->
		res.view "pages/capture"
