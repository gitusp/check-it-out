require [], ->
	stage = $ '#stage'
	workSpace = $ '#draw-work-space'

	window.bootstrap = (stringifiedDna) ->
		dna = JSON.parse stringifiedDna

		# set up stage
		stage.css {
				width: dna.width
				height: dna.height
				backgroundImage: "url(#{dna.image})"
				backgroundPosition: "#{dna.offsetX}px #{dna.offsetY}px"
			}

		# # create rects
		# if dna.rects?
		# 	for r in dna.rects
		# 		rect = new drawRect {x: r.x, y: r.y}, r.borderColor, r.borderWidth
		# 		rect.pointMutable.x = r.x + r.width
		# 		rect.pointMutable.y = r.y + r.height
		# 		rect.draw()
		# 		workSpace.append rect.entity

		# wait for image loaded
		setTimeout ->
				window.imagesReady = true
			, 0
