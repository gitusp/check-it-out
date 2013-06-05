define ['models/clip', 'models/draw', 'models/stage', 'models/share', 'etc/rect', 'etc/drawRect'], (clip, draw, stage, share, rect, drawRect) ->
	useragent = navigator.userAgent.toLowerCase()

	class app
		constructor: ->
			# appModel
			@state = ko.observable 'portal'
			@nonBase64 = null

			# to fix scpne
			@emulateBrowse = (d, e) =>
				$(e.target).closest('form').find('input[type=file]').click()
			@upload = (d, e) =>
				$(e.target).closest('form').submit()
			@clip = (d, e) =>
				@editor 'clip'
			@draw = (d, e) =>
				@editor 'draw'
			@share = (d, e) =>
				return if @editor() == 'share'
				@editor 'share'

				# 圧縮完了時に呼び出す
				done = (preClipped = false, imageSource = @imageSource()) =>
					rects = for rect in @rects()
						{
							x: rect.getLeft()
							y: rect.getTop()
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
						offsetX: if preClipped then 0 else @stageOffsetX()
						offsetY: if preClipped then 0 else @stageOffsetY()
						rects: rects
					}
					@shareCallback(json)

				if ! @nonBase64 and Modernizr.canvas
					# try to compress data
					[canvas] = $("<canvas width=\"#{@stageWidth()}\" height=\"#{@stageHeight()}\">")
					context = canvas.getContext '2d'
					[img] = $('<img>').on('load', =>
							context.drawImage img, @stageOffsetX(), @stageOffsetY()
							tmpImageSource = canvas.toDataURL()
							if tmpImageSource.length < @imageSource().length
								done(true, tmpImageSource)
							else
								done()
						).attr 'src', @imageSource()
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

			# help
			@hideHelp = =>
				@help false
			@showHelp = =>
				@help true
			@help = ko.observable false

			# pseudo super
			clip.apply @, arguments
			draw.apply @, arguments
			stage.apply @, arguments
			share.apply @, arguments

		# fixed val, feature detection
		appUnavailable: /msie (6|7)|iphone|android|ipad|ipod/.test useragent # old msie and touch devices
		canOptimizeViewPort: /chrome|firefox|msie/.test useragent # exclude safari
		canPasteImage: /chrome/.test useragent
		canDropImage: !!window.FileReader && Modernizr.draganddrop
		needRealFileInput: /msie/.test useragent

		# methods
		setShareCallback: (@shareCallback) ->

		# extender
		@reopen: (defs...) ->
			for def in defs
				@::[key] = val for key, val of def.prototype

	app.reopen clip, draw, stage, share
	drawRect.setAppModel clip.setAppModel rect.setAppModel draw.setAppModel new app
