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
			@optimizeViewport()
			appModel.dragging true
			basePoint = $.extend true, {}, @pointMutable
			workSpace.on 'mousemove.draw', (e) =>
				@pointMutable.x = basePoint.x + e.pageX - initialPoint.x
				@pointMutable.y = basePoint.y + e.pageY - initialPoint.y
				@normalize @pointMutable
				@draw()

			workSpace.on 'mouseup.draw', (e) =>
				appModel.dragging false
				workSpace.off 'mousemove.draw mouseup.draw'
				@dispose() unless @getWidth() * @getHeight()

		startDrag: (initialPoint) ->
			appModel.dragging true
			basePointFixed = $.extend true, {}, @pointFixed
			basePointMutable = $.extend true, {}, @pointMutable
			workSpace.on 'mousemove.drag', (e) =>
				@pointFixed.x = basePointFixed.x + e.pageX - initialPoint.x
				@pointFixed.y = basePointFixed.y + e.pageY - initialPoint.y
				@pointMutable.x = basePointMutable.x + e.pageX - initialPoint.x
				@pointMutable.y = basePointMutable.y + e.pageY - initialPoint.y
				@normalize @pointFixed
				@normalize @pointMutable
				@draw()

			workSpace.on 'mouseup.drag', (e) =>
				appModel.dragging false
				workSpace.off 'mousemove.drag mouseup.drag'
				@dispose() unless @getWidth() * @getHeight()

		optimizeViewport: ->
			# conf
			pad = 70
			transition = 8

			# flag
			toBreak = false

			(=>
					x = 0
					y = 0
					nowX = if @pointMutable.x < @pointFixed.x then @entity.offset().left else @entity.offset().left + @getWidth()
					nowY = if @pointMutable.y < @pointFixed.y then @entity.offset().top else @entity.offset().top + @getHeight()

					# about x
					overX = nowX - $window.width() - $window.scrollLeft() + pad
					if overX > 0
						x = overX / transition
					else
						overX = nowX - $window.scrollLeft() - pad
						x = overX / transition if overX < 0

					# about y
					overY = nowY - $window.height() - $window.scrollTop() + pad
					if overY > 0
						y = overY / transition
					else
						overY = nowY - $window.scrollTop() - pad
						y = overY / transition if overY < 0

					window.scrollBy x, y
					setTimeout arguments.callee, 13 unless toBreak
				)()

			workSpace.on 'mouseup.optimize', (e) =>
				workSpace.off 'mouseup.optimize'
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
