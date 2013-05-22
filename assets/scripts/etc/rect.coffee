define [], (appModel) ->
	workSpace = $ document

	class
		constructor: (@pointFixed = {x: 0, y: 0}, @borderWidth = 0, @borderColor = 'transparent') ->
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

			# duplicate point
			@pointMutable = $.extend true, {}, @pointFixed

			# entity
			@entity = $('<div class="rect">').on('mousedown', (e) ->
					e.stopPropagation()
				).css {
					backgroundImage: "url(#{appModel.imageSource()})"
				}

			# border
			if @borderWidth > 0
				$('<div class="border-top">').height(@borderWidth).css('background', @borderColor).appendTo @entity
				$('<div class="border-right">').width(@borderWidth).css('background', @borderColor).appendTo @entity
				$('<div class="border-bottom">').height(@borderWidth).css('background', @borderColor).appendTo @entity
				$('<div class="border-left">').width(@borderWidth).css('background', @borderColor).appendTo @entity

		redraw: ->
			clearTimeout @lock
			@lock = setTimeout =>
				# TODO: adjust points by comparing with chache
				@draw()
			, 0

		draw: ->
			bgpx = - @getLeft() + appModel.stageOffsetX()
			bgpy = - @getTop() + appModel.stageOffsetY()
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
