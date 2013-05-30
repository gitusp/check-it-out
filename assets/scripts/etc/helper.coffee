define [], ->
	transitionEndEvent = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'

	ko.bindingHandlers.dissolveCSS3 = 
		init: (element, valueAccessor) ->
			value = ko.utils.unwrapObservable valueAccessor()
			unless value
				$(element).hide()

		update: (element, valueAccessor) ->
			value = ko.utils.unwrapObservable valueAccessor()
			$element = $ element
			if value
				$element.show()
				setTimeout ->
						$element.removeClass 'dissolve-out' if Modernizr.csstransitions
					, 0
			else
				if Modernizr.csstransitions
					$element.addClass 'dissolve-out'
					if $element.is ':visible'
						$element.on transitionEndEvent, ->
							$element.off transitionEndEvent, arguments.callee
							$element.hide()
				else
					$element.hide()
