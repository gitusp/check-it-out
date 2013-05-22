define ['models/app'], (appModel) ->
	class
		constructor: (@borderWidth = 0) ->
			@subscriptions = []
			@subscriptions.push(appModel.stageWidth.subscribe (oldValue) ->
					@cachedStageWidth = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(appModel.stageHeight.subscribe (oldValue) ->
					@cachedStageHeight = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(appModel.stageOffsetX.subscribe (oldValue) ->
					@cachedStageOffsetX = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(appModel.stageOffsetY.subscribe (oldValue) ->
					@cachedStageOffsetY = oldValue
					@redraw()
				, @, 'beforeChange')

		redraw: ->
			clearTimeout @lock
			@lock = setTimeout ->
				# TODO: redraw by comparing with chache
				console.log 'redraw'
			, 0

		dispose: ->
			for s in @subscriptions
				s.dispose()
