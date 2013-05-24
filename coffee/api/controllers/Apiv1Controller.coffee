fs = require("fs")
client = require("capture/client")

randobet = (n) ->
	a = ('abcdefghijklmnopqrstuvwxyz'+ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+ '0123456789').split ''
	s = for i in [0..n]
		a[Math.random() * a.length | 0]
	s.join ''

module.exports =
	# init by upload
	upload: (req, res) ->
		# TODO: tmp tableに格納
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
		myClient.run (data64) ->
			data = new Buffer(data64.toString(), 'base64')

			# hashを生成
			hash = ''
			createHash = ->
				hash = randobet 12
				Image.find(hash: hash).done (err, img) ->
					unless img? then save() else createHash()

			# dataを保存
			save = ->
				Image.create(hash: hash, image: data).done (err, img) ->
					unless err
						res.json status: 'success', hash: hash
					else
						# TODO: fallback

			# run
			createHash()

	# シェア用
	show: (req, res) ->
		Image.find(hash: req.param 'hash').done (err, img) ->
			unless err
				res.setHeader 'Content-Type', 'image/png'
				res.end img.image
			else
				# TODO: fallback
