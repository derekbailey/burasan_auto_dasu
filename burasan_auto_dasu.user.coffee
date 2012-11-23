###
// ==UserScript==
// @name        burasan auto dasu
// @description burasan auto dasu
// @namespace   http://github.com/derekbailey
// @include     http://*.3gokushi.jp/busyodas/busyodas.php
// @version     0.1
// ==/UserScript==
###

getSSID = ->
  document.querySelectorAll('input[name=ssid]')[0].value

getAkiwaku = ->
  parseInt document.querySelectorAll('.sysMes > strong')[2].textContent, 10

getBP = ->
  document.querySelector('#status_right').textContent.match(/([0-9]+)/)[0]

createTempElement = (parentElement) ->
  elm = document.createElement('div')
  elm.id = 'TempElement'
  parentElement.appendChild elm
  parentElement.querySelector '#TempElement'

createTextarea = ->
  ta = document.createElement('textarea')
  ta.style.width = '90%'
  ta.style.height = '20em'
  ta.id = 'resultCard'

  document.body.insertBefore ta, document.body.firstChild
  ta = document.createElement('textarea')
  ta.style.width = '80%'
  ta.style.height = '1em'
  ta.id = 'resultMessage'

  document.body.insertBefore ta, document.body.firstChild
  ta = document.createElement('textarea')
  ta.style.width = '10%'
  ta.style.height = '1em'
  ta.id = 'resultCount'
  document.body.insertBefore ta, document.body.firstChild

  true

draw = ->
  xhr = new XMLHttpRequest()
  xhr.open 'POST', 'http://' + location.hostname + '/busyodas/busyodas.php'
  xhr.onreadystatechange = (res) ->
    if xhr.readyState is 4 and xhr.status is 200
      temp = createTempElement(document.body)
      temp.innerHTML = res.target.responseText
      message = temp.querySelectorAll('div.sysMes2 p.bushodas_card')[0].textContent
      if temp.querySelectorAll('span.rarerity_c').length
        rare = 'C'
      else if temp.querySelectorAll('span.rarerity_uc').length
        rare = 'UC'
      else if temp.querySelectorAll('span.rarerity_r').length
        rare = 'R'
      else if temp.querySelectorAll('span.rarerity_sr').length
        rare = 'SR'
      else if temp.querySelectorAll('span.rarerity_ur').length
        rare = 'UR'

      #console.log(rare + message);
      document.querySelector('#resultCard').textContent += rare + message + '\n'
      temp.parentNode.removeChild temp

  xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
  xhr.send 'ssid=' + getSSID() + '&send=send&got_type=0'

getCount = ->
  akiwaku = getAkiwaku()
  kaisuu = parseInt(getBP() / 100, 10)

  return 0  if akiwaku <= 0 or kaisuu <= 0

  if kaisuu < akiwaku
    kaisuu
  else
    akiwaku

msg = (s) ->
  document.querySelector('#resultMessage').textContent = s

main = ->
  count = getCount()
  sleep = 5 # sec

  return false  if count <= 0

  # テキストエリアを初期化
  createTextarea()
  document.querySelector('#resultCount').textContent = "Count: #{count.toString()}"

  # 待ち時間タイマー
  time = sleep - 1
  waitTimer = setInterval(->
    time = sleep - 1  if time < 0
    msg "Waiting...(#{time.toString()})"
    time--
  , 1000)

  # カード引きタイマー
  drawTimer = setInterval(->
    draw()
    count--
    document.querySelector('#resultCount').textContent = "Count: #{count.toString()}"
    if count <= 0
      clearInterval drawTimer
      clearInterval waitTimer
      msg 'End'
      false
  , sleep * 1000)

###
console.log('SSID: ' + getSSID());
console.log('Waku: ' + getAkiwaku());
console.log('BP: ' + getBP());
console.log('Count: ' + getCount());
console.log('createElement: ' + createTempElement(document.body));
console.log('createTextarea: ' + createTextarea());
msg('test');
###

bt = document.createElement('button')
bt.textContent = 'AUTO DASU'
bt.style.width = '100%'
bt.addEventListener 'mouseover', ->
  @style.cursor = 'pointer'

bt.addEventListener 'click', main

document.querySelector('#sidebar').insertBefore(
  bt, document.querySelector('#sidebar').firstChild)


