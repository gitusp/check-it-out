define ['models/clip', 'models/draw', 'models/stage', 'etc/rect', 'etc/drawRect'], (clip, draw, stage, rect, drawRect) ->
	useragent = navigator.userAgent.toLowerCase()

	class app
		constructor: ->
			# appModel
			@state = ko.observable 'portal'

			# to fix scpne
			@upload = (d, e) =>
				$(e.target).closest('form').submit()
			@clip = (d, e) =>
				@editor 'clip'
			@draw = (d, e) =>
				@editor 'draw'
			@share = (d, e) =>
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
					image: @imageSource()
					width: @stageWidth()
					height: @stageHeight()
					offsetX: @stageOffsetX()
					offsetY: @stageOffsetY()
					rects: rects
				}
				@shareCallback(json)
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

		# fixed val, feature detection
		appUnavailable: /msie (6|7)/.test useragent
		canPasteImage: /chrome/.test useragent
		canDropImage: /chrome|safari|firefox|msie 1/.test useragent

		# methods
		setShareCallback: (@shareCallback) ->

		# extender
		@reopen: (defs...) ->
			for def in defs
				@::[key] = val for key, val of def.prototype

	app.reopen clip, draw, stage
	drawRect.setAppModel clip.setAppModel rect.setAppModel draw.setAppModel new app
