define ['etc/clipRect'], (clipRect, appModel) ->
	workSpace = $ '#clip-work-space'
	[mask1, mask2, mask3, mask4] = for i in [1..4]
		$ ".mask#{i}", workSpace
	rect = null

	# methods
	maskResizer = (top = 0, right = 0, bottom = 0, left = 0) ->
		mask1.height(top).width appModel.stageWidth() - left
		mask2.height(appModel.stageHeight() - top).width appModel.stageWidth() - right
		mask3.height(appModel.stageHeight() - bottom).width right
		mask4.height(bottom).width left

	clean = ->
		rect.dispose() if rect?
		rect = null
		maskResizer()

	class
		constructor: ->
			# to fix scope
			@startClip = (d, e) =>
				clean()
				offset = workSpace.offset()
				rect = new clipRect {x: e.pageX - offset.left, y: e.pageY - offset.top}, maskResizer
				workSpace.append rect.entity
				rect.startDraw {x: e.pageX, y: e.pageY}

		_clip: ->
			if rect
				med = {
					offsetX: @stageOffsetX()
					offsetY: @stageOffsetY()
					width: @stageWidth()
					height: @stageHeight()
				}
				to = {
					offsetX: @stageOffsetX() - rect.getLeft()
					offsetY: @stageOffsetY() - rect.getTop()
					width: rect.getWidth()
					height: rect.getHeight()
				}

				$(med).animate to, {
						duration: 500
						easing: "swing"
						step: (now, fx) =>
							@stageOffsetX med.offsetX | 0
							@stageOffsetY med.offsetY | 0
							@stageWidth med.width | 0
							@stageHeight med.height | 0
					}

			@editor null

		# static
		@setAppModel = (am) ->
			am.editor.subscribe (newValue) ->
				clean() if newValue == 'clip'
			appModel = am
