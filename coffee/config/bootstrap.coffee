# App bootstrap
# Code to run before launching the app
cronJob = require('cron').CronJob
sv = require 'local_shared_values'
dateformat = require 'dateformat'

# Make sure you call cb() when you're finished.
module.exports.bootstrap = (cb) ->
	# cleaner job (every hour)
	new cronJob '0 0 * * * *', ->
			return unless Image?

			# do clean expired tmp
			date = new Date (new Date).getTime() - 60 * 60 * 24 * 1000
			expire = dateformat date, "yyyy-mm-dd HH:MM:ss"
			Image.destroy {createdAt: {'<': expire}, tmp: 1}, (err, img) ->
				unless err then console.log 'cleanedUp' else console.log 'err'

			# do clean expired image
			date = new Date (new Date).getTime() - sv.imageMaxAge
			expire = dateformat date, "yyyy-mm-dd HH:MM:ss"
			Image.destroy {createdAt: {'<': expire}, tmp: 0}, (err, img) ->
				unless err then console.log 'cleanedUp' else console.log 'err'

		, null, true

	cb()
