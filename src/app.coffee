


do->
	lastSchedules=[]
	rooms={}
	roomIds=[2246,2319,3622,6186,41430]
	apiScheduleList="http://douyu.sashi-con.info/api/list"
	apiRoomStatus="http://www.douyutv.com/api/client/room/"

	getSchedules=()->

		$.get apiScheduleList,(data,status,xhr)->
			schedules= JSON.parse(data)




			lastSchedules=schedules

		# xhr = new XMLHttpRequest()
		# xhr.open "GET", apiScheduleList, true
		# console.log "xhr opend"
		# xhr.onreadystatechange =()->
		# 	console.log "change on ready"+xhr.readyState
		# 	if xhr.readyState is 4
		# 		console.log xhr.responseText
		# 		schedules = JSON.parse(xhr.responseText)
		# 		console.log schedules
		# 	return
		# xhr.send()





	getRoomStatus=()->
		for i in roomIds
			$.get "#{apiRoomStatus}#{i}",(data)->

				roomStatus=JSON.parse(data)
				console.log "fetched room status: #{roomStatus.data.room_id}"
				_updateRoomStatus(roomStatus)

	_updateRoomStatus=(roomStatus)->
		if roomStatus.error is 0
			roomId=parseInt(roomStatus.data.room_id)|0
			rooms[roomId]=roomStatus.data
			console.log "roomStatus updated: #{roomId}"




	getSchedules()

	getRoomStatus()

	setInterval getSchedules,300000
