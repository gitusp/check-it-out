define ['models/clip', 'models/stage'], (clip, stage) ->
	useragent = navigator.userAgent.toLowerCase()

	appModel = new class
		constructor: ->
			# appModel
			@state = ko.observable 'portal'

			# methodだとスコープ固定できないので
			@upload = (d, e) =>
				$(e.target).closest('form').submit()
			@clip = (d, e) =>
				@editor 'clip'
			@draw = (d, e) =>
				@editor 'draw'
			@share = (d, e) =>
				# TODO: JSONize myself
				json = {}
				@shareCallback(json)

		# feature detection
		appUnavailable: /msie (6|7)/.test useragent
		canPasteImage: /chrome/.test useragent
		canDropImage: /chrome|safari|firefox|msie 1/.test useragent

		# methods
		setShareCallback: (@shareCallback) ->

		# module sys
		include: (objs...) ->
			for obj in objs
				@[name] = method for name, method of obj
			@

	appModel.include clip, stage