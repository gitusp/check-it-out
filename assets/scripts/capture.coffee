require ['models/app', 'etc/drawRect'], (appModel, drawRect) ->
	workSpace = $ '#draw-work-space'

	window.bootstrap = (stringifiedDna) ->
		dna = JSON.parse stringifiedDna

		# set up stage
		appModel.imageSource dna.image
		appModel.stageWidth dna.width
		appModel.stageHeight dna.height
		appModel.stageOffsetX dna.offsetX
		appModel.stageOffsetY dna.offsetY

		# create rects
		if dna.rects?
			for r in dna.rects
				rect = new drawRect {x: r.x, y: r.y}, r.borderColor, r.borderWidth
				rect.pointMutable.x = r.x + r.width
				rect.pointMutable.y = r.y + r.height
				rect.draw()
				workSpace.append rect.entity

		ko.applyBindings appModel, document.body

		# wait for image loaded
		setTimeout ->
				window.imagesReady = true
			, 0

		# $('<img>').on('load', ->
		# 		window.imagesReady = true
		# 	).attr 'src', dna.image
