define ['models/clip', 'models/draw', 'models/stage', 'models/share', 'etc/rect', 'etc/drawRect'], (clip, draw, stage, share, rect, drawRect) ->
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
		# NOTE: msie 1は推測と希望
		canDropImage: /chrome|safari|firefox|msie 1/.test useragent

		# extender
		@reopen: (defs...) ->
			for def in defs
				@::[key] = val for key, val of def.prototype

	app.reopen clip, draw, stage, share
	drawRect.setAppModel clip.setAppModel rect.setAppModel draw.setAppModel new app
