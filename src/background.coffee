schedules=[]
scheduleChanged=false
lastSchedules=[]


rooms=[]
roomsStatus={}

apiScheduleList="http://douyu.sashi-con.info/api/list"
apiScheduleRoom="http://douyu.sashi-con.info/api/room"
apiSnap="http://douyu.sashi-con.info/snap"

# This function takes an object |imageSpec| with the key |path| -
# corresponding to the internet URL to be translated - and optionally
# |width| and |height| which are the maximum dimensions to be used when
# converting the image.
loadImageData = (imageSpec, callbacks) ->
  path = imageSpec.path
  img = new Image()
  img.crossOrigin = 'anonymous'
  if typeof callbacks.onerror is "function"
    img.onerror = ->
      callbacks.onerror
        problem: "could_not_load"
        path: path

      return
  img.onload = ->
    canvas = document.createElement("canvas")
    if img.width <= 0 or img.height <= 0
      callbacks.onerror
        problem: "image_size_invalid"
        path: path

      return
    scaleFactor = 1
    scaleFactor = imageSpec.width / img.width  if imageSpec.width and imageSpec.width < img.width
    if imageSpec.height and imageSpec.height < img.height
      heightScale = imageSpec.height / img.height
      scaleFactor = heightScale  if heightScale < scaleFactor
    canvas.width = img.width * scaleFactor
    canvas.height = img.height * scaleFactor
    canvas_context = canvas.getContext("2d")
    canvas_context.clearRect 0, 0, canvas.width, canvas.height
    canvas_context.drawImage img, 0, 0, canvas.width, canvas.height
    try
      imageData = canvas_context.getImageData(0, 0, canvas.width, canvas.height)
      callbacks.oncomplete imageData.width, imageData.height, imageData.data.buffer  if typeof callbacks.oncomplete is "function"
    catch e
      if typeof callbacks.onerror is "function"
        callbacks.onerror
          problem: "data_url_unavailable"
          path: path

    return

  img.src = path
  return

base64ToBlob = (base64Data, type) ->
  sliceSize = 1024
  byteCharacters = atob(base64Data)
  bytesLength = byteCharacters.length
  slicesCount = Math.ceil(bytesLength / sliceSize)
  byteArrays = new Array(slicesCount)
  sliceIndex = 0

  while sliceIndex < slicesCount
    begin = sliceIndex * sliceSize
    end = Math.min(begin + sliceSize, bytesLength)
    bytes = new Array(end - begin)
    offset = begin
    i = 0

    while offset < end
      bytes[i] = byteCharacters[offset].charCodeAt(0)
      ++i
      ++offset
    byteArrays[sliceIndex] = new Uint8Array(bytes)
    ++sliceIndex
  new Blob(byteArrays,
    type: type
  )


getBase64Image=(img)->

	canvas=document.createElement("canvas")
	canvas.width=img.width
	canvas.height=img.height

	ctx=canvas.getContext("2d")
	ctx.clearRect 0,0,canvas.width,canvas.height
	ctx.drawImage img,0,0,canvas.width,canvas.height

	# imageData=ctx.getImageData(0,0,canvas.width,canvas.height)

	return canvas.toDataURL("image/jpg")

	# return dataUrl.replace(/^data:image\/(png|jpg);base64,/, "")


setBadge=(text)->
	chrome.browserAction.setBadgeText(text:text)

showScheduleNotification=()->
	# notification=webkitNotifications.createNotification('images/icon64.png','hello','body')
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

	# items=schedules.map (s)->
	# 	start=s.end.split('～')[0]
	# 	{title:"#{s.begin} #{start}",message:s.description}


	cbk=
		oncomplete:(width,height,data)->
			console.log width


	# imgUrl=room.room_src.replace("http://staticlive.douyutv.com/upload/web_pic",apiSnap)
	# loadImageData({path:imgUrl},cbk)

	img=new Image()
	img.crossOrigin = 'anonymous'
	img.src=room.room_src.replace("http://staticlive.douyutv.com/upload/web_pic",apiSnap)
	img.onload=(data)->

		imgData=getBase64Image(img)

		options=
			type:"image"
			iconUrl:'images/icon89.png'
			title: "#{room.room_name}"
			imageUrl:imgData
			message: 'happy happy harurupi~'

		chrome.notifications.create(
			""
			options
			(notificationId)->
		)


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

	# We reached our target server, but it returned an error
	request.onerror=()->

	# There was a connection error of some sort
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

				roomsStatus[r.room_id]=r.show_status

		return

	request.onerror=()->

	request.send()


do->
	console.log "background loaded"
	# getSchedules()
	setInterval getSchedules,5000
	setInterval getRooms,5000
