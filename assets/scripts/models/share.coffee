define ['etc/lang'], (lang) ->
	class
		constructor: ->
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
			@resultUrl = ko.observable()
			@deleteKey = ko.observable()
			@deleteKeyHasBeenSet = ko.observable false

			# to fix scope
			@setDeleteKey = (d, e) =>
				$.post '/api/v1/key', {key: @deleteKey()}, (json) =>
						switch json.result
							when 'success'
								@deleteKeyHasBeenSet true
							when 'exception'
								alert lang.errorInServer
							when 'tooshort'
								alert lang.tooShortDeleteKey
					, 'json'

		# methods
		setShareCallback: (@shareCallback) ->
