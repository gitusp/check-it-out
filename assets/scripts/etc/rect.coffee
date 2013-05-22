define [], (appModel) ->
	workSpace = $ document

	class
		constructor: (@pointFixed = {x: 0, y: 0}) ->
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

			# init point
			@pointMutable = $.extend true, {}, @pointFixed
			for pt in [@pointFixed, @pointMutable]
				@normalize pt

			# entity
			@entity = $('<div class="rect">').on 'mousedown', (e) ->
					e.stopPropagation()

		redraw: ->
			clearTimeout @lock
			@lock = setTimeout =>
				# TODO: adjust points by comparing with chache
				@draw()
			, 0

		draw: ->
			@entity.css {
					left: @getLeft()
					top: @getTop()
					width: @getWidth()
					height: @getHeight()
				}

		# NOTE: startPointはwrapperはさんでもpage基準でいいのか？
		# 		どちらにせよwrapperスクロールするために参照どこかで持ちそうなきがする
		startDraw: (initialPoint) ->
			basePoint = $.extend true, {}, @pointMutable
			workSpace.mousemove (e) =>
				@pointMutable.x = basePoint.x + e.pageX - initialPoint.x
				@pointMutable.y = basePoint.y + e.pageY - initialPoint.y
				@normalize @pointMutable
				@draw()

			workSpace.mouseup (e) =>
				workSpace.off 'mousemove mouseup'

		# rangesafe point setter
		normalize: (pt) ->
			pt.x = if pt.x < 0 then 0 else pt.x
			pt.y = if pt.y < 0 then 0 else pt.y
			pt.x = if pt.x > appModel.stageWidth() then appModel.stageWidth() else pt.x
			pt.y = if pt.y > appModel.stageHeight() then appModel.stageHeight() else pt.y

		# getter
		getLeft: -> Math.min @pointFixed.x, @pointMutable.x
		getTop: -> Math.min @pointFixed.y, @pointMutable.y
		getRight: -> Math.max @pointFixed.x, @pointMutable.x
		getBottom: -> Math.max @pointFixed.y, @pointMutable.y
		getWidth: -> @getRight() - @getLeft()
		getHeight: -> @getBottom() - @getTop()

		# destructor
		dispose: ->
			for s in @subscriptions
				s.dispose()
			@entity.remove()

		# static
		@setAppModel: (am) ->
			appModel = am
