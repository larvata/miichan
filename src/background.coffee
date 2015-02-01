schedules=[]
scheduleChanged=false
lastSchedules=[]


rooms=[]
roomsStatus={}

apiScheduleList="http://douyu.sashi-con.info/api/list"
apiScheduleRoom="http://douyu.sashi-con.info/api/room"
apiSnap="http://douyu.sashi-con.info/snap"
apiAvatar="http://douyu.sashi-con.info/avatar/"

getBase64Image=(img)->

	canvas=document.createElement("canvas")
	canvas.width=img.width
	canvas.height=img.height

	ctx=canvas.getContext("2d")
	ctx.clearRect 0,0,canvas.width,canvas.height
	ctx.drawImage img,0,0,canvas.width,canvas.height

	return canvas.toDataURL("image/jpg")


setBadge=(text)->
	chrome.browserAction.setBadgeText(text:text)

showScheduleNotification=()->
	items=schedules.map (s)->
		start=s.end.split('～')[0]
		{title:"#{s.begin} #{start}",message:s.description}


	options=
		type:"list"
		iconUrl:'images/icon89.png'
		title: 'douyu schedule updated'
		message: 'happy happy harurupi~'
		items:items


	chrome.notifications.create(
		"6666"
		options
		(notificationId)->
	)

showRoomNotification=(room)->

	img=new Image()
	img.crossOrigin = 'anonymous'
	img.src=room.room_src.replace("http://staticlive.douyutv.com/upload/web_pic",apiSnap)
	img.onload=(data)->

		imgData=getBase64Image(img)


		imgAvatar=new Image()
		imgAvatar.crossOrigin='anonymous'
		imgAvatar.src=apiAvatar+room.owner_uid

		imgAvatar.onload=(data)->

			avatarData=getBase64Image(imgAvatar)

			d=new Date(room.show_time*1000)

			formattedTime ="#{d.getFullYear()}/#{d.getMonth()+1}/#{d.getDay()+1} #{d.getHours()}:#{('0'+d.getMinutes()).substr(d.getMinutes().toString().length-1)}:#{('0'+d.getSeconds()).substr(d.getSeconds().toString().length-1)}"

			message ="于 #{formattedTime} 开播"

			message += "\t#{room.show_details}"

			options=
				type:"image"
				iconUrl: avatarData
				title: "#{room.room_name}"
				imageUrl:imgData
				message: message

			chrome.notifications.create(
				room.room_id.toString()
				options
				(notificationId)->
			)


clearRoomNotification=(room)->
	chrome.notifications.clear room.room_id.toString(),()->

getSchedules=()->
	request = new XMLHttpRequest()
	request.open "GET", apiScheduleList, true
	request.onload=()->
		if request.status >= 200 and request.status < 400

			# Success!
			schedules = JSON.parse(request.responseText)

			if JSON.stringify(schedules) is JSON.stringify(lastSchedules)

			else
				setBadge('!')
				showScheduleNotification()


			lastSchedules=schedules
		else

		return
	request.onerror=()->

	request.send()


getRooms=()->
	request=new XMLHttpRequest()
	request.open "GET", apiScheduleRoom,true
	request.onload=()->
		if request.status>=200 and request.status<400
			rooms=JSON.parse(request.responseText)

			for r in rooms
				if roomsStatus[r.room_id] is r.show_status

				else if r.show_status == 1
					showRoomNotification(r)
				else if r.show_status == 2
					clearRoomNotification(r)

				roomsStatus[r.room_id]=r.show_status

		return
	request.onerror=()->

	request.send()


do->
	console.log "background loaded"
	getSchedules()
	getRooms()
	setInterval getSchedules,120000
	setInterval getRooms,120000
