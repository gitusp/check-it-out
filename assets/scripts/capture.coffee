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

		# create rects
		if dna.rects?
			workSpace.addClass('hasRect')
			for r in dna.rects
				# base
				bgpx = - (~~r.x) + (~~dna.offsetX)
				bgpy = - (~~r.y) + (~~dna.offsetY)
				rect = $('<div class="rect">').css {
						backgroundImage: "url(#{dna.image})"
						backgroundPosition: "#{bgpx}px #{bgpy}px"
						left: "#{r.x}px"
						top: "#{r.y}px"
						width: r.width
						height: r.height
					}
	
				# shadow
				$('<div class="shadow">').appendTo rect

				# border
				$('<div class="border-top">').height(r.borderWidth).css('background', r.borderColor).appendTo rect
				$('<div class="border-right">').width(r.borderWidth).css('background', r.borderColor).appendTo rect
				$('<div class="border-bottom">').height(r.borderWidth).css('background', r.borderColor).appendTo rect
				$('<div class="border-left">').width(r.borderWidth).css('background', r.borderColor).appendTo rect

				# ok
				workSpace.append rect

		# wait for image loaded
		setTimeout ->
				window.imagesReady = true
			, 0
