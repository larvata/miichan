schedules=[]
scheduleChanged=false

birthdayMembers=[]

lastSchedules=[]
birthdayNotify=""


rooms=[]
roomsStatus={}
roomsShowTime={}

scheduleNotificationId="6666"

# apiDomain="127.0.0.1:3434"
apiDomain="live.sashi.co"

apiScheduleList="http://#{apiDomain}/api/list"
apiScheduleRoom="http://#{apiDomain}/api/room"
apiSnap="http://#{apiDomain}/snap"
apiAvatar="http://#{apiDomain}/avatar"




getBase64Image=(img)->

  canvas=document.createElement("canvas")
  canvas.width=img.width
  canvas.height=img.height

  ctx=canvas.getContext("2d")
  ctx.clearRect 0,0,canvas.width,canvas.height
  ctx.drawImage img,0,0,canvas.width,canvas.height

  return canvas.toDataURL("image/jpg")

getBirthdayMembers=()->

  date = new Date()
  m = _.padLeft(date.getMonth()+1,2,"0")
  d = _.padLeft(date.getDate(),2,"0")
  dateString = "#{m}/#{d}"

  # return _.chain(birthday).where({date:dateString}).pluck('name').value().join(',')
  return _.chain(birthday).where({date:dateString}).value()


setBadge=(text)->
  console.log "try setBadgeText: #{text}"
  chrome.browserAction.setBadgeText(text:text)

showBirthdayNotification=()->


showScheduleNotification=()->
  items=schedules.map (s)->
    start=s.end.split('～')[0]
    {title:"#{s.begin} #{start}",message:s.description}

  chrome.notifications.clear scheduleNotificationId,()->
    options=
      type:"list"
      iconUrl:'images/icon128.png'
      title: '节目单更新'
      message: '<null>'
      items:items
    chrome.notifications.create scheduleNotificationId,options,(notificationId)->


showRoomNotification=(room)->

  img=new Image()
  img.crossOrigin = 'anonymous'
  # img.src=room.live_snapshot.replace("http://staticlive.douyutv.com/upload/web_pic",apiSnap)
  switch room.live_provider
    when 'douyu'
      img.src=apiSnap+'/douyu'+room.live_snapshot
    when 'zhanqi'
      img.src=apiSnap+'/zhanqi'+room.live_snapshot
  img.onload=(data)->

    imgData=getBase64Image(img)
    imgAvatar=new Image()
    imgAvatar.crossOrigin='anonymous'
    switch room.live_provider
      when 'douyu'
        imgAvatar.src=apiAvatar+'/douyu'+room.owner_avatar
      when 'zhanqi'
        imgAvatar.src=apiAvatar+'/zhanqi'+room.owner_avatar
    
    

    imgAvatar.onload=(data)->

      avatarData=getBase64Image(imgAvatar)
      d = room.show_time
      dn = Date.now()
      diffMinutes = dn - d

      message ="已播#{diffMinutes}分钟 "
      message += "#{room.show_details}"

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

getBirthday=()->
  console.log "getBirthday"
  birthday = getBirthdayMembersName()


getSchedules=()->
  console.log "getSchedules"
  $.getJSON apiScheduleList,(data,status)->
    if status isnt 'success'
      console.log "Failed: getSchedules(#{apiScheduleList}) status: #{status}"
      return

    # Success!
    schedules = data
    console.log "schedules:"
    console.log schedules
    console.log "lastSchedules:"
    console.log lastSchedules
    if _.isEqual(schedules,lastSchedules)
      # not changed
      console.log "equal"
    else
      setBadge('!')
      showScheduleNotification()

    lastSchedules=schedules
    chrome.storage.sync.set({lastSchedules})

  setTimeout getSchedules,120000

getRooms=()->
  console.log "getRooms"
  $.getJSON apiScheduleRoom,(data,status)->
    if status isnt 'success'
      console.log "Failed: getRooms(#{apiScheduleRoom}) status: #{status}"
      return

    rooms=data

    for r in rooms
      if r.show_status == 1
        if roomsStatus[r.room_id] is r.show_status
          if r.show_time != roomsShowTime[r.room_id]
            clearRoomNotification(r)
            showRoomNotification(r)
        else
          showRoomNotification(r)
      else
        clearRoomNotification(r)

      roomsStatus[r.room_id]=r.show_status
      roomsShowTime[r.room_id]=r.show_time

  setTimeout getRooms,120000


# init
# load lastSchedules from chrome storage
console.log "init"
chrome.storage.sync.get ["lastSchedules"],(items)->
  {lastSchedules} = items
  console.log "load lastSchedules"
  console.log lastSchedules

  do->
    ret = getBirthdayMembersName()
    console.log ret
    getSchedules()
    getRooms()
    getBirthday()
  

