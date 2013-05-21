define ['etc/lang'], (lang) ->
	useragent = navigator.userAgent.toLowerCase()

	new class
		constructor: ->
			# feature detection
			@appUnavailable = /msie (6|7)/.test useragent
			@canPasteImage = /chrome/.test useragent
			@canDropImage = /chrome|safari|firefox|msie 1/.test useragent

			# appModel
			@imageSource = ko.observable '/images/spacer.gif'
			@state = ko.observable 'portal'
			@editor = ko.observable()

			# methods
			@upload = (d, e) ->
				(($ e.target).closest 'form').submit()
			@imageError = ->
				alert lang.unsupportedImage
			@clip = =>
				@editor 'clip'
			@draw = =>
				@editor 'draw'
