
do->

	getSchedules=()->
		xhr = new XMLHttpRequest()
		xhr.open "GET", "http://localhost:3434/api/list", true
		console.log "xhr opend"
		xhr.onreadystatechange =()->
			console.log "change on ready"+xhr.readyState
			if xhr.readyState is 4
				console.log xhr.responseText
				schedules = JSON.parse(xhr.responseText)
				console.log schedules
			return
		xhr.send()



	roomIds=[2246,2319,3622,6186,41430]

	getRoomStatus=()->



	setInterval getSchedules,300000
