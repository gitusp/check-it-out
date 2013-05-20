require [], ->
	step = 0
	steps = [
		{
			enter: ->
				# TODO: bind paste
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

	viewModel = new class
		constructor: ->
			@state = ko.observable 'portal'

	ko.applyBindings viewModel, document.body

	# boot strap
	next()
