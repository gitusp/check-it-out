fs = require 'fs'
client = require 'capture/client'
sv = require 'local_shared_values'
crypto = require 'crypto'
uuid = require 'uuid'
dateformat = require 'dateformat'

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

# 画像を出力
display = (hash, res) ->
	Image.find(hash: hash).done (err, img) ->
		if ! err and img?
			res.setHeader 'Content-Type', "image/#{img.type}"
			res.setHeader 'Expires', new Date(Date.now() + 60 * 60 * 24 * 1000).toUTCString()
			res.end img.image
		else
			res.view '404'

# 
# main
# 
module.exports =
	# 
	# init by upload
	# 
	upload: (req, res) ->
		image = req.files.image
		return res.view "pages/upload", uploadStatus: 'exception' unless image?

		# type判別
		if /image\/p?jpe?g/.test image.type
			type = 'jpg'
		else if /image\/(x-)?png/.test image.type
			type = 'png'
		else if /image\/gif/.test image.type
			type = 'gif'
		else
			type = 'unk'

		# dataを保存
		unless type == 'unk'
			# size判定
			return res.view "pages/upload", uploadStatus: 'toolargeimage' if image.size > sv.imageMaxBytes

			# 保存
			fs.readFile image.path, (err, data) ->
				unless err
					createHash (hash) ->
						Image.create(hash: hash, image: data, type: type, tmp: true).done (err, img) ->
							unless err
								res.view "pages/upload", uploadStatus: 'success', image: "\"/i/#{hash}\""
							else
								res.view "pages/upload", uploadStatus: 'exception'

				else
					res.view "pages/upload", uploadStatus: 'exception'
		else
			res.view "pages/upload", uploadStatus: 'unsupportedimage'

	# 
	# end edit
	# 
	share: (req, res) ->
		dna = req.param 'dna'
		dna.port = sv.port
		runClient = (dna) ->
			myClient = new client dna
			myClient.run (data64) ->
				if data64?
					data = new Buffer data64.toString(), 'base64'

					# dataを保存
					createHash (hash) ->
						Image.create(hash: hash, image: data, type: 'png', tmp: false).done (err, img) ->
							unless err
								# expire
								future = new Date (new Date).getTime() + sv.imageMaxAge
								expire = dateformat future, "yyyy/mm/dd HH:MM:ss"

								# token
								token = uuid.v4()
								req.session.keyToken = req.session.keyToken || {}
								req.session.keyToken[token] = img.id
								res.json status: 'success', url: "/s/#{hash}", token: token, expire: expire
							else
								res.json status: 'failure'

				# phantomjsゴケ
				else
					res.json status: 'failure'


		if dna.nonBase64
			# アップロードしているほう
			tmpHash = dna.image.split('/').pop()
			Image.find(hash: tmpHash).done (err, img) ->
				if ! err and img?
					dna.image = "data:#{img.type};base64," + img.image.toString 'base64'
					dna.nonBase64 = null
					runClient dna
				else
					res.json status: 'failure'
		else
			# なうでデータ送ってきてるほう
			return res.json status: 'failure' if ! dna.image?
			return res.json status: 'toolargeimage' if dna.image.length * 3 / 4 > sv.imageMaxBytes
			runClient dna

	# 
	# シェア用
	# 
	show: (req, res) ->
		if /facebookexternalhit/.test req.header 'user-agent'
			# ogp出力
			res.view 'pages/facebookexternalhit', hash: req.param 'hash'
		else
			# 画像出力
			display req.param('hash'), res
	
	# 
	# 画像を出力する
	# 
	image: (req, res) ->
		display req.param('hash'), res

	# 
	# set delete key
	# 
	key: (req, res) ->
		key = req.param 'key', ''
		token = req.param 'token', ''
		imageId = if req.session.keyToken? then req.session.keyToken[token] else null

		# has session?
		return res.json status: 'exception' unless imageId?

		# ok do
		hash = ''
		if key
			shasum = crypto.createHash 'sha1'
			shasum.update key
			hash = shasum.digest 'hex'

		Image.update imageId, {key: hash}, (err, img) ->
			if ! err
				res.json status: 'success'
			else
				res.json status: 'exception'

	# 
	# confirm
	# 
	confirm: (req, res) ->
		key = req.param 'key', ''
		hash = req.param 'hash', ''
		return res.view '404' unless key

		shasum = crypto.createHash 'sha1'
		shasum.update key
		key = shasum.digest 'hex'

		# ok find by sha1
		Image.find(hash: hash, key: key).done (err, img) ->
			if ! err and img?
				token = uuid.v4()
				req.session.deleteToken = req.session.deleteToken || {}
				req.session.deleteToken[token] = img.id
				res.view 'pages/delete', mode: 'form', token: token, imageSource: "/s/#{hash}"
			else
				res.view '404'

	# 
	# delete
	# 
	delete: (req, res) ->
		token = req.param 'token', ''
		imageId = if req.session.deleteToken? then req.session.deleteToken[token] else null

		# has session?
		return res.view 'pages/delete', mode: 'done', error: true unless imageId?

		Image.destroy imageId, (err, img) ->
			res.view 'pages/delete', mode: 'done', error: err
