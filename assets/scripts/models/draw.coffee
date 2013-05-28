define ['etc/drawRect'], (drawRect, appModel) ->
	workSpace = $ '#draw-work-space'

	class
		constructor: ->
			# to fix scope
			@startDraw = (d, e) =>
				offset = workSpace.offset()
				@drawRect = new drawRect {x: e.pageX - offset.left, y: e.pageY - offset.top}
				workSpace.append @drawRect.entity
				@drawRect.startDraw {x: e.pageX, y: e.pageY}
				e.preventDefault()

		# static
		@setAppModel: (am) ->
			am.rects.subscribe (newValue) ->
				if newValue.length > 0 then workSpace.addClass('hasRect') else workSpace.removeClass('hasRect')
			appModel = am
