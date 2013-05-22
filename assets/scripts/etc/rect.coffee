define ['models/stage'], (stage) ->
	workSpace = $(document)

	class
		constructor: (@borderWidth = 0, @pointFixed = {x: 0, y: 0}) ->
			@subscriptions = []
			@subscriptions.push(stage.stageWidth.subscribe (oldValue) ->
					@cachedStageWidth = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(stage.stageHeight.subscribe (oldValue) ->
					@cachedStageHeight = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(stage.stageOffsetX.subscribe (oldValue) ->
					@cachedStageOffsetX = oldValue
					@redraw()
				, @, 'beforeChange')
			@subscriptions.push(stage.stageOffsetY.subscribe (oldValue) ->
					@cachedStageOffsetY = oldValue
					@redraw()
				, @, 'beforeChange')

			# duplicate point
			@pointMutable = $.extend true, {}, @pointFixed

			# entity
			@entity = $('<div class="rect">').on('mousedown', (e) ->
					e.stopPropagation()
				).css {
					borderWidth: @borderWidth
					backgroundImage: "url(#{stage.imageSource()})"
				}

		redraw: ->
			clearTimeout @lock
			@lock = setTimeout =>
				# TODO: adjust points by comparing with chache
				@draw()
			, 0

		draw: ->
			# TODO: care about border
			bgpx = - @getLeft() + stage.stageOffsetX()
			bgpy = - @getTop() + stage.stageOffsetY()
			@entity.css {
					left: @getLeft()
					top: @getTop()
					width: @getWidth()
					height: @getHeight()
					backgroundPosition: "#{bgpx}px #{bgpy}px"
				}

		# NOTE: startPointはwrapperはさんでもpage基準でいいのか？
		# 		どちらにせよwrapperスクロールするために参照どこかで持ちそうなきがする
		# 		いまだと領域超えちゃうしね
		startDraw: (prevPoint) ->
			workSpace.mousemove (e) =>
				newPoint = {x: e.pageX, y: e.pageY}
				@pointMutable.x += newPoint.x - prevPoint.x
				@pointMutable.y += newPoint.y - prevPoint.y
				prevPoint = newPoint
				@draw()

			workSpace.mouseup (e) =>
				workSpace.off 'mousemove mouseup'

		# TODO: care about border
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
