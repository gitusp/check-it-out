define [], ->
	useragent = navigator.userAgent.toLowerCase()

	new class
		constructor: ->
			# feature detection
			@appUnavailable = /msie (6|7)/.test useragent
			@canPasteImage = /chrome/.test useragent
			@canDropImage = /chrome|safari|firefox|msie 1/.test useragent

			# appModel
			@imageSource = ko.observable '/images/spacer.gif'
			@stageWidth = ko.observable 0
			@stageHeight = ko.observable 0
			@stageOffsetX = ko.observable 0
			@stageOffsetY = ko.observable 0
			@state = ko.observable 'portal'
			@editor = ko.observable()

			# model for submit
			@rects = ko.observableArray()

			# methods
			@upload = (d, e) ->
				$(e.target).closest('form').submit()
			@clip = =>
				@editor 'clip'
			@draw = =>
				@editor 'draw'
