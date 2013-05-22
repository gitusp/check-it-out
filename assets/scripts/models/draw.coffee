define ['etc/drawRect'], (drawRect, appModel) ->
	workSpace = $ '#draw-work-space'

	class
		constructor: ->
			# to fix scope
			@startDraw = (d, e) =>
				@drawRect = new drawRect {x: e.offsetX, y: e.offsetY}, 'black'
				workSpace.append @drawRect.entity
				@drawRect.startDraw {x: e.pageX, y: e.pageY}

				# add to models rects
				appModel.rects.push @drawRect

		# static
		@setAppModel: (am) ->
			am.rects.subscribe (newValue) ->
				if newValue.length > 0 then workSpace.addClass('hasRect') else workSpace.removeClass('hasRect')
			appModel = am
