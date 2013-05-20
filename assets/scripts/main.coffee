require [], ->
	step = 0
	steps = [
		{
			enter: ->
				($ document).on 'click', ->
					alert 'check it out!'
			exit: ->
				($ document).off 'click'
		}
		{
			enter: ->
			exit: ->
		}
	]
	next = ->
		if steps[step - 1]
			steps[step - 1].exit()
		steps[step].enter()
		step++

	next()
