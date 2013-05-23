require ['models/app', 'etc/drawRect'], (appModel, drawRect) ->
	workSpace = $ '#draw-work-space'

	# set up stage
	appModel.imageSource DNA.image
	appModel.stageWidth DNA.width
	appModel.stageHeight DNA.height
	appModel.stageOffsetX DNA.offsetX
	appModel.stageOffsetY DNA.offsetY

	# create rects
	for r in DNA.rects
		rect = new drawRect {x: r.x, y: r.y}, r.borderColor, r.borderWidth
		rect.pointMutable.x = r.x + r.width
		rect.pointMutable.y = r.y + r.height
		rect.draw()
		workSpace.append rect.entity

	ko.applyBindings appModel, document.body
