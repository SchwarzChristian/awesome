-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("wicked")

function msg(s)
   _, res = pcall(function() return s .. "(" .. type(s) .. ")" end)
   naughty.notify({title = "msg", text = res, timeout = 10})
end

-- net
myNetWidget = widget({type = "textbox"})
function net(s)
   if (s == "wlan") then
      wicked.register(myNetWidget, wicked.widgets.net, ' <span color="white">wlan</span>: ${wlan0 down} / ${wlan0 up}', nil, nil, 3)
   elseif (s == "lan") then
      wicked.register(myNetWidget, wicked.widgets.net, ' <span color="white">lan</span>: ${eth0 down} / ${eth0 up}', nil, nil, 3)
   elseif (s == "mobile") then
      wicked.register(myNetWidget, wicked.widgets.net, ' <span color="white">UMTS</span>: ${ppp0 down} / ${ppp0 up}', nil, nil, 3)
   else
      wicked.unregister(myNetWidget)
      myTextField.text = ""
   end
end
-- end net

-- cpu
cpugraphwidget = widget({
   type = 'graph',
   name = 'cpugraphwidget',
   align = 'right'
})

cpugraphwidget.height = 0.85
cpugraphwidget.width = 45
cpugraphwidget.bg = '#333333'
cpugraphwidget.border_color = '#0a0a0a'
cpugraphwidget.grow = 'right'

cpugraphwidget:plot_properties_set('cpu', {
   fg = '#AEC6D8',
   fg_center = '#285577',
   fg_end = '#285577',
   vertical_gradient = false
})

wicked.register(cpugraphwidget, wicked.widgets.cpu, '$1', 1, 'cpu')
-- end cpu

-- battery
myBatteryWidget = widget({type = "imagebox"})
function batteryUpdate()
   local p = io.popen(incpath .. "battery.ruby")
   local value = tonumber(p:read())
   local img = image.argb32(50, 20, nil)

   if (value > 1) then value = 1
   elseif (value < 0) then value = 0 
   end
   if (p:read()) then
      c = "#FFFF00"
   else
      c = "#00FF00"
   end
   img:draw_rectangle(0, 0, 50, 20, true, "#000000") --clear
   img:draw_rectangle(0, 4, 50, 10, true, "#7F0000") --bg
   img:draw_rectangle(0, 4, 50 * value, 10, true, c) --fg
   myBatteryWidget.image = img
end

wicked.register(myBatteryWidget, batteryUpdate, nil, 60)
-- end battery

