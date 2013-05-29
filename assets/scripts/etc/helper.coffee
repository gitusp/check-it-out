define [], ->
	ko.bindingHandlers.dissolveCSS3 = 
		init: (element, valueAccessor) ->
			value = ko.utils.unwrapObservable valueAccessor()
			$element = $ element
			unless value
				$element.hide()
				# TODO: detect by Modernizr
				# $element.addClass('dissolve-out')

		update: (element, valueAccessor) ->
			value = ko.utils.unwrapObservable valueAccessor()
			# TODO: detect by Modernizr
			# if can disolve
			# $(element).fadeIn() : $(element).fadeOut();
