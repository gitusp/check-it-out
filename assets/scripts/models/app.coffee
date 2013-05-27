define ['models/clip', 'models/draw', 'models/stage', 'models/share', 'etc/rect', 'etc/drawRect'], (clip, draw, stage, share, rect, drawRect) ->
	useragent = navigator.userAgent.toLowerCase()

	class app
		constructor: ->
			# appModel
			@state = ko.observable 'portal'
			@nonBase64 = null

			# to fix scpne
			@upload = (d, e) =>
				$(e.target).closest('form').submit()
			@clip = (d, e) =>
				@editor 'clip'
			@draw = (d, e) =>
				@editor 'draw'
			@share = (d, e) =>
				# use for adjustment
				adjustOffsetX = 0
				adjustOffsetY = 0
				imageSource = @imageSource()

				# next
				done = =>
					rects = for rect in @rects()
						{
							x: rect.getLeft() + adjustOffsetX
							y: rect.getTop() + adjustOffsetY
							width: rect.getWidth()
							height: rect.getHeight()
							borderWidth: rect.borderWidth
							borderColor: rect.borderColor
						}
					json = {
						image: imageSource
						nonBase64: @nonBase64
						width: @stageWidth()
						height: @stageHeight()
						offsetX: @stageOffsetX() - adjustOffsetX
						offsetY: @stageOffsetY() - adjustOffsetY
						rects: rects
					}
					@shareCallback(json)

				if ! @nonBase64 and Modernizr.canvas
					# try to compress data
					[canvas] = $("<canvas width=\"#{@stageWidth()}\" height=\"#{@stageHeight()}\">")
					context = canvas.getContext '2d'
					[img] = $('<img>').on('load', =>
							context.drawImage img, -@stageOffsetX(), -@stageOffsetY(), @stageWidth(), @stageHeight(), 0, 0, @stageWidth(), @stageHeight()
							tmpImageSource = canvas.toDataURL()
							if tmpImageSource.length < @imageSource().length
								# is compressed?
								imageSource = tmpImageSource
								adjustOffsetX = @stageOffsetX()
								adjustOffsetY = @stageOffsetY()
							done()
						).attr 'src', imageSource
				else
					# direct output
					done()


			# common UI
			@done = (d, e) =>
				switch @editor()
					when 'clip'
						@doClip()
					when 'draw'
						@editor null
			@cancel = (d, e) =>
				@editor null

			# pseudo super
			clip.apply @, arguments
			draw.apply @, arguments
			stage.apply @, arguments
			share.apply @, arguments

		# fixed val, feature detection
		# TODO: 再調査、ただアップロードでかなり対応したはず、z-indexがあやしいけどはじくほどでもないだろう
		appUnavailable: false#/msie (6|7)/.test useragent
		canPasteImage: /chrome/.test useragent
		canDropImage: !!window.FileReader && Modernizr.draganddrop

		# methods
		setShareCallback: (@shareCallback) ->

		# extender
		@reopen: (defs...) ->
			for def in defs
				@::[key] = val for key, val of def.prototype

	app.reopen clip, draw, stage, share
	drawRect.setAppModel clip.setAppModel rect.setAppModel draw.setAppModel new app
