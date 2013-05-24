fs = require("fs")
client = require("capture/client")

# hashがユニークになるまでトライ
createHash = (callback) ->
	randobet = (n) ->
		a = ('abcdefghijklmnopqrstuvwxyz'+ 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+ '0123456789').split ''
		s = for i in [0..n]
			a[Math.random() * a.length | 0]
		s.join ''

	htry = ->
		hash = randobet 12
		Image.find(hash: hash).done (err, result) ->
			unless result? then callback(hash) else htry()

	htry()

# 
# main
# 
module.exports =
	# 
	# init by upload
	# 
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
					createHash (hash) ->
						Image.create(hash: hash, image: data, type: type, tmp: true).done (err, img) ->
							unless err
								res.view "pages/upload", status: 'success', image: "\"/s/#{hash}\""
							else
								res.view "pages/upload", status: 'exception'

				else
					res.view "pages/upload", status: 'exception'
		else
			res.view "pages/upload", status: 'unsupportedimage'

	# 
	# end edit
	# 
	share: (req, res) ->
		dna = req.param 'dna'
		runClient = (dna) ->
			myClient = new client dna
			myClient.run (data64) ->
				if data64?
					data = new Buffer(data64.toString(), 'base64')

					# dataを保存
					createHash (hash) ->
						Image.create(hash: hash, image: data, type: 'png', tmp: false).done (err, img) ->
							unless err
								res.json status: 'success', hash: hash
							else
								res.json status: 'failure'

				# phantomjsゴケ
				else
					res.json status: 'failure'


		# アップロード組か否か
		if req.param 'hasTmpImage'
			tmpHash = dna.image.split('/').pop()
			Image.find(hash: tmpHash).done (err, img) ->
				if ! err and img?
					dna.image = "data:#{img.type};base64," + img.image.toString("base64")
					runClient dna
				else
					res.json status: 'failure'
		else
			runClient dna

	# 
	# シェア用
	# 
	show: (req, res) ->
		Image.find(hash: req.param 'hash').done (err, img) ->
			if ! err and img?
				res.setHeader 'Content-Type', "image/#{img.type}"
				res.setHeader 'Expires', new Date(Date.now() + 60 * 60 * 24 * 365 * 1000).toUTCString()
				res.end img.image
			else
				res.view '404'
