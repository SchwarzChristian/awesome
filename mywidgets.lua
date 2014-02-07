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
netData = {ifaces = {"wlan0", "ppp0", "eth0"}, iface = 1}
netData.data = {}

function netData:getiface()
   if (self.iface < 0 or self.iface > #self.ifaces) then return nil end
   return self.ifaces[self.iface]
end

local img = image.argb32(150, 18, nil)
myNetWidget.bg_image = img
local cycle = 0

function netUpdate()
   img:draw_rectangle(0, 0, 150, 18, true, "#004000") --clear
   img:draw_rectangle(42, 1, 52, 16, true, "#006F00") --bg
   img:draw_rectangle(97, 1, 52, 16, true, "#006F00") --bg
   cycle = cycle + 1
   
   local p = io.popen(incpath .. "net.ruby " .. netData:getiface())
   local iface = p:read()
   if (not iface) then return {iface = "<span strikethrough='true'>" .. netData:getiface() .. "</span>"} end
   local tx = tonumber(p:read())
   local rx = tonumber(p:read())
   local data
   local maxvalue

   if (netData.last) then
      netData.data[#(netData.data)+1] = {
	 tx = tx - netData.last.tx, 
	 rx = rx - netData.last.rx
      }
      netData.last = {
	 tx = tx, 
	 rx = rx,
	 maxtx = math.max(netData.last.maxtx, tx - netData.last.tx),
	 maxrx = math.max(netData.last.maxrx, rx - netData.last.rx)
      }
   else
      netData.last = {tx = tx, rx = rx, maxtx = 0, maxrx = 0}
      return netUpdate()
   end

   if (netData.last.maxtx == 0 and netData.last.maxrx == 0) then return {iface = "<span strikethrough='true'>" .. netData:getiface() .. "</span>"} end

   if (#netData.data > 50) then
      for i = 1, 56 do
	 netData.data[i] = netData.data[i+1]
      end
      for i = 57, #netData.data do
	 netData.data[i] = nil
      end
   end

   data = netData.data

   if (cycle > 0) then
      local t, r = 0, 0
      for _, d in pairs(data) do
	 t = math.max(t, d.tx)
	 r = math.max(r, d.rx)
      end
      netData.last.maxtx, netData.last.maxrx = t, r
      cycle = 0
   end
   
   offset = 50 - #data
   for i = 1, #data do
      vt, vr = 15 - data[i].tx / netData.last.maxtx * 13, 15 - data[i].rx / netData.last.maxrx * 13
      if (data[i].tx > 0) then img:draw_line(43 + i + offset, vt, 43 + i + offset, 15, "#FF0000") end
      if (data[i].rx > 0) then img:draw_line(97 + i + offset, vr, 97 + i + offset, 15, "#00FF00") end
   end

   return {iface = netData:getiface()}
end

myNetWidget:buttons(awful.button({ }, 1, function()
   local i = netData.iface
   i = i + 1
   if (i > #netData.ifaces) then i = 1 end
   netData.iface = i
   netData.data = {}
   netData.last = nil
end))

wicked.register(myNetWidget, netUpdate, '<span color="#00FF00">$iface</span>', 1)
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
myBatteryWidget = widget({type = "textbox"})
myBatteryWidget.color = "#00FFFF"
local batData = {}
function batteryUpdate()
   local p = io.popen(incpath .. "battery.ruby")
   local state = p:read()
   local value = tonumber(p:read()) / 100
   local time = p:read()
   local img = image.argb32(50, 18, nil)

   if (value > 1) then value = 1
   elseif (value < 0) then value = 0 
   end
   if (state == "Discharging") then
      c = "#FFFF00"
   else
      c = "#00FF00"
   end
   img:draw_rectangle(0, 0, 50, 18, true, "#004000") --clear
   img:draw_rectangle(0, 14, 50, 4, true, "#7F0000") --bg
   img:draw_rectangle(0, 14, 50 * value, 4, true, c) --fg
   myBatteryWidget.bg_image = img
   return {t = "  " .. (#time > 0 and time or "  Full"), p = value * 100}
end

myBatteryWidget:buttons(awful.button({ }, 1, batteryUpdate))
wicked.register(myBatteryWidget, batteryUpdate, "<span gravity='north' color='#00FF00'>$t</span>", 60)
-- end battery
