fs = require("fs")
client = require("capture/client")

randobet = (n) ->
	a = ('abcdefghijklmnopqrstuvwxyz'+ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+ '0123456789').split ''
	s = for i in [0..n]
		a[Math.random() * a.length | 0]
	s.join ''

createHash = (model, callback) ->
	hash = randobet 12
	model.find(hash: hash).done (err, result) ->
		unless result? then callback(hash) else createHash()

module.exports =
	# init by upload
	upload: (req, res) ->
		# type判別
		if /image\/p?jpe?g/.test req.files.image.type
			type = 'jpg'
		else if /image\/(x-)?png/.test req.files.image.type
			type = 'png'
		else if /image\/gif/.test req.files.image.type
			type = 'gif'
		else
			type = 'unk'

		# dataを保存
		unless type == 'unk'
			fs.readFile req.files.image.path, (err, data) ->
				unless err
					save = (hash) ->
						Tmp.create(hash: hash, image: data, type: type).done (err, img) ->
							unless err
								res.view "pages/upload", status: 'success', image: "\"/t/#{hash}\""
							else
								res.view "pages/upload", status: 'exception'

					# hashを生成
					createHash Tmp, save

				else
					res.view "pages/upload", status: 'exception'
		else
			res.view "pages/upload", status: 'unsupportedimage'

	# end edit
	share: (req, res) ->
		dna = req.param 'dna'
		runClient = (dna) ->
			myClient = new client dna
			myClient.run (data64) ->
				data = new Buffer(data64.toString(), 'base64')

				# dataを保存
				save = (hash) ->
					Image.create(hash: hash, image: data).done (err, img) ->
						unless err
							res.json status: 'success', hash: hash
						else
							# TODO: fallback

				# hashを生成
				createHash Image, save

		# アップロード組か否か
		if req.param 'hasTmpImage'
			tmpHash = dna.image.split('/').pop()
			Tmp.find(hash: tmpHash).done (err, img) ->
				unless err
					dna.image = "data:#{img.type};base64," + img.image.toString("base64")
					runClient dna
				else
					# TODO: fallback
		else
			runClient dna

	# シェア用
	show: (req, res) ->
		Image.find(hash: req.param 'hash').done (err, img) ->
			unless err
				res.setHeader 'Content-Type', 'image/png'
				res.end img.image
			else
				# TODO: fallback

	# 仮表示用
	tmp: (req, res) ->
		Tmp.find(hash: req.param 'hash').done (err, img) ->
			unless err
				res.setHeader 'Content-Type', "image/#{img.type}"
				res.end img.image
			else
				# TODO: fallback
