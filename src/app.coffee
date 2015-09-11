
window.onload=()->
  console.log(birthday)

  renderSchedule()
  renderRoom()

# newTab=(room_id)->
#   url="http://www.douyutv.com/"+room_id
#   chrome.tabs.create(url:url)


renderSchedule=()->

  schedules=chrome.extension.getBackgroundPage().schedules

  scheduleHtml=''
  for s in schedules
    scheduleHtml+="<div class='schedule'>"
    scheduleHtml+="<div>"
    scheduleHtml+="<span class='time'>#{s.end}</span><span class='channel'>#{s.begin}</span>"
    scheduleHtml+="</div>"
    scheduleHtml+="<div>"
    scheduleHtml+="<span class='programm'>#{s.description}</span>"
    scheduleHtml+="</div>"
    scheduleHtml+="</div>"

  document.getElementById('scheduleList').innerHTML=scheduleHtml

  chrome.extension.getBackgroundPage().setBadge('')


renderRoom=()->

  rooms=chrome.extension.getBackgroundPage().rooms

  roomHtml=''

  for r in rooms
    roomClass=''
    if r.show_status isnt 2
      switch r.live_provider
        when "douyu"
          roomClass='button-douyu'
        when "zhanqi"
          roomClass='button-zhanqi'


    roomHtml+="<li class='layout-item-module layout-item-module-base'>"
    roomHtml+="<button title='关注人数:#{r.fans}' class='open-tab-button pure-button #{roomClass}' data-room-url='#{r.room_url}' data-live-provider='#{r.live_provider}'>#{r.room_name} (#{r.online})</button>"
    roomHtml+="</li>"

  document.getElementById('roomList').innerHTML=roomHtml


  btns=document.getElementsByClassName('open-tab-button')

  for b in btns
    b.addEventListener 'click',()->
      switch @attributes['data-live-provider'].value
        when 'douyu'
          url="http://www.douyutv.com"+@attributes['data-room-url'].value
        when 'zhanqi'
          url="http://www.zhanqi.tv"+@attributes['data-room-url'].value
      
      chrome.tabs.create(url:url)



