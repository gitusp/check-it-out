define [], (appModel) ->
	workSpace = $ document
	$window = $ window

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
			@entity = $('<div class="rect">').on 'mousedown', (e) =>
				e.stopPropagation()

			# resizer
			$('<div class="handle-nw">').on('mousedown', (e) =>
					e.stopPropagation()
					bounds = @getBounds()
					@pointFixed.x = bounds.right
					@pointFixed.y = bounds.bottom
					@pointMutable.x = bounds.left
					@pointMutable.y = bounds.top
					@startDraw {x: e.pageX, y: e.pageY}
				).appendTo @entity
			$('<div class="handle-ne">').on('mousedown', (e) =>
					e.stopPropagation()
					bounds = @getBounds()
					@pointFixed.x = bounds.left
					@pointFixed.y = bounds.bottom
					@pointMutable.x = bounds.right
					@pointMutable.y = bounds.top
					@startDraw {x: e.pageX, y: e.pageY}
				).appendTo @entity
			$('<div class="handle-se">').on('mousedown', (e) =>
					e.stopPropagation()
					bounds = @getBounds()
					@pointFixed.x = bounds.left
					@pointFixed.y = bounds.top
					@pointMutable.x = bounds.right
					@pointMutable.y = bounds.bottom
					@startDraw {x: e.pageX, y: e.pageY}
				).appendTo @entity
			$('<div class="handle-sw">').on('mousedown', (e) =>
					e.stopPropagation()
					bounds = @getBounds()
					@pointFixed.x = bounds.right
					@pointFixed.y = bounds.top
					@pointMutable.x = bounds.left
					@pointMutable.y = bounds.bottom
					@startDraw {x: e.pageX, y: e.pageY}
				).appendTo @entity

			# set draggable
			@entity.on 'mousedown.drag', (e) =>
				@startDrag {x: e.pageX, y: e.pageY}

		redraw: ->
			clearTimeout @lock
			@lock = setTimeout =>
				diffOffsetX = @cachedStageOffsetX - appModel.stageOffsetX()
				diffOffsetY = @cachedStageOffsetY - appModel.stageOffsetY()

				for pt in [@pointFixed, @pointMutable]
					pt.x -= diffOffsetX
					pt.y -= diffOffsetY
					@normalize pt

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
			@optimizeViewport(initialPoint)
			appModel.dragging true
			basePoint = $.extend true, {}, @pointMutable
			workSpace.on 'mousemove.draw', (e, x = e.pageX, y = e.pageY) =>
				@pointMutable.x = basePoint.x + x - initialPoint.x
				@pointMutable.y = basePoint.y + y - initialPoint.y
				@normalize @pointMutable
				@draw()

			workSpace.on 'mouseup.draw', (e) =>
				appModel.dragging false
				workSpace.off 'mousemove.draw mouseup.draw'
				@dispose() unless @getWidth() * @getHeight()

		startDrag: (initialPoint) ->
			@optimizeViewport(initialPoint)
			appModel.dragging true
			basePointFixed = $.extend true, {}, @pointFixed
			basePointMutable = $.extend true, {}, @pointMutable
			workSpace.on 'mousemove.drag', (e, x = e.pageX, y = e.pageY) =>
				@pointFixed.x = basePointFixed.x + x - initialPoint.x
				@pointFixed.y = basePointFixed.y + y - initialPoint.y
				@pointMutable.x = basePointMutable.x + x - initialPoint.x
				@pointMutable.y = basePointMutable.y + y - initialPoint.y
				@normalize @pointFixed
				@normalize @pointMutable
				@draw()

			workSpace.on 'mouseup.drag', (e) =>
				appModel.dragging false
				workSpace.off 'mousemove.drag mouseup.drag'
				@dispose() unless @getWidth() * @getHeight()

		optimizeViewport: (initialPoint) ->
			# conf
			pad = 70
			transition = 8

			# v
			toBreak = false
			lastPoint = initialPoint

			(=>
					x = 0
					y = 0
					scrollLeft = $window.scrollLeft()
					scrollTop = $window.scrollTop()
					innerWidth = $window.width()
					innerHeight = $window.height()

					# about x
					overX = lastPoint.x - innerWidth - scrollLeft + pad
					if overX > 0 and scrollLeft + innerWidth < workSpace.width()
						x = overX / transition
					else if overX < 0 and scrollLeft > 0
						overX = lastPoint.x - scrollLeft - pad
						x = overX / transition if overX < 0

					# about y
					overY = lastPoint.y - innerHeight - scrollTop + pad
					if overY > 0 and scrollTop + innerHeight < workSpace.height()
						y = overY / transition
					else if overY < 0 and scrollTop > 0
						overY = lastPoint.y - scrollTop - pad
						y = overY / transition if overY < 0

					# adj
					x = x|0
					y = y|0
					window.scrollBy x, y
					workSpace.trigger 'mousemove', [lastPoint.x + x, lastPoint.y + y]
					setTimeout arguments.callee, 13 unless toBreak
				)()

			workSpace.on 'mousemove.optimize', (e, x = e.pageX, y = e.pageY) =>
				lastPoint = x: x, y: y

			workSpace.on 'mouseup.optimize', (e) =>
				workSpace.off 'mousemove.optimize mouseup.optimize'
				toBreak = true

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
		getBounds: -> {top: @getTop(), right: @getRight(), bottom: @getBottom(), left: @getLeft()}

		# destructor
		dispose: ->
			for s in @subscriptions
				s.dispose()
			@entity.remove()

		# static
		@setAppModel: (am) ->
			appModel = am
