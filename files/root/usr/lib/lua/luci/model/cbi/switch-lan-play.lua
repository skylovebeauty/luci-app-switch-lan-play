
require("luci.sys")

m = Map("switch-lan-play", translate("Switch Lan Play"), translate("Switch Can Lan Play With Friends."))

s = m:section(TypedSection, "server", "")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable", translate("Enable"))



relay_server_ip = s:option(Value, "relay_server_ip", translate("relay_server_ip"))
relay_server_port = s:option(Value, "relay_server_port", translate("relay_server_port"))

ifname = s:option(ListValue, "ifname", translate("Interfaces"))

 for k, v in ipairs(luci.sys.net.devices()) do
     if v ~= "lo" then
         ifname:value(v)
     end
 end
 
local apply = luci.http.formvalue("cbi.apply")
if apply then
     io.popen("/etc/init.d/switch-lan-play restart")
 end
 
 return m