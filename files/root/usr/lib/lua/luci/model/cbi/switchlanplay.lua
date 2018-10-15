-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local fs  = require "nixio.fs" 
local sys = require "luci.sys"
local cjson = require "luci.json"

local inits = { }
local run_server = { }

local play_on = (luci.sys.call("pidof lan-play > /dev/null"))==0

local state_msg = " "


if play_on then

   local now_server = io.popen("ps | grep lan-play | grep -v 'grep' | cut -d ' ' -f 15")
   local server_info = now_server:read("*all") 
   now_server:close()

   state_msg="<b><font color=\"green\">" .. translate("Running") .. "</font></b>"  .. "<p><p>Current Server Address    " .. server_info 

else                                                                                                                  
     
   state_msg="<b><font color=\"red\">" .. translate("Stopped")  .. "</font></b>"
                                                                                                                 
end  


m = Map("switchlanplay", translate("Switch Lan Play"), translate("Switch Can Lan Play With Friends.") .. "<p><p>" ..translate("Status") .. " - " .. state_msg)

r = m:section(TypedSection, "run_server", translate("Server_Set"))
r.addremove = false
r.anonymous = true

enable = r:option(Flag, "enable", translate("Enable"))

ifname = r:option(ListValue, "ifname", translate("Interfaces"), translate("Same as your Switch Ip interface"))

 for k, v in ipairs(luci.sys.net.devices()) do
     if v ~= "lo" then
         ifname:value(v)
     end
 end

manually  = r:option(Flag, "manually", translate("manually"),translate("Select manually or Server Lists")) 

relay_server_ip = r:option(Value, "relay_server_ip", translate("relay_server_ip"), translate("Server IP ,Must Input"))                                                                                                                       
relay_server_ip.datatype="ip4addr"                                                                                                                                                                                                           
relay_server_ip.default='119.51.174.208'

                                                                                                                                                                                                                                             
relay_server_port = r:option(Value, "relay_server_port", translate("relay_server_port"),translate("Server Port ,Must Input"))                                                                                                                
relay_server_port.datatype="integer"                                                                                                                                                                                                         
relay_server_port.default=11451                                                                                                                                                                                                              


 
-- local apply = luci.http.formvalue("cbi.apply")


--if apply then
--    io.popen("uci commit switchlanplay")
--    io.popen("/etc/init.d/switchlanplay restart")
--    luci.util.exec("/etc/init.d/switchlanplay restart")
-- end



local f_server=io.open("/etc/switchlanplay_list.json","r")                                                 
                                            
local t_server = f_server:read("*all")                    
f_server:close()                                   
                                            
local server_data = cjson.decode(t_server)
                                                                                                  
--if server_data == nil then                                                                               
--        print("Json error")                                                                       
--end                                                                                               
                                                                                                  

--print (data["update_time"])


local inits,attr = {}
                           
for k_len=1, table.getn(server_data["list"]) do                                  
        for i_len , j_len  in pairs(server_data["list"][k_len]) do

           inits[k_len] = {}   
	   inits[k_len].s_name = server_data["list"][k_len]["name"]                                                                                                       
	   inits[k_len].s_address =  server_data["list"][k_len]["address"]                                                                                   
	   inits[k_len].s_description = server_data["list"][k_len]["description"] 
        end                                    
end



--[[

inits[1] = {}
inits[1].s_name = '000'
inits[1].s_address = '1.1.1.1:444'
inits[1].s_description = 'xxx'

inits[2] = {}                                                                                         
inits[2].s_name = '001'                                                                               
inits[2].s_address = '1.1.1.2:22'                                                                    
inits[2].s_description = 'xxx22'
--]]




f = m:section(Table,inits,translate("Server_List"),translate("List Servers"))

s_name = f:option(DummyValue, "s_name", translate("Server Name"))

s_address = f:option(DummyValue, "s_address",translate("Server Address")) 
s_description = f:option(DummyValue, "s_description", translate("Server Description"))

--function s_name.cfgvalue(self, section)
--end


start = f:option(Button, "start", translate("Run"))                                                 
start.inputstyle = "apply"                                                                            
--start.write = function(self, section)                                                                 

function start.write(self, section, value)
 
--	sys.call("pgrep lan-play | xargs -r kill -9 > /dev/null")


--	sys.call("lan-play --relay-server-addr %s --黣tif wlan0 & >/dev/null" %{ inits[section].s_address })
	
	sys.call("uci set switchlanplay.@run_server[0].enable=1 > /dev/null")
	sys.call("uci delete switchlanplay.@run_server[0].manually > /dev/null")
	sys.call("uci set switchlanplay.@run_server[0].sever_list=%s >/dev/null" %{ inits[section].s_address })
	sys.call("uci commit switchlanplay > /dev/null ")
	sys.call("luci-reload > /dev/null ")
	sys.call("/etc/init.d/switchlanplay restart >/dev/null ")
	luci.http.write("<script>location.href='./switchlanplay';</script>")

--        sys.call("/etc/init.d/%s %s >/dev/null" %{ inits[section].s_address, self.option })                
	return 
end   

--local up_time = server_data["update_time"]

local up_time = os.date("%Y-%m-%d %H:%M:%S",server_data["update_time"])


uplist = r:option(Button, "uplist", translate("Update Server List"), translate("After pressing the button please wait 10 seconds<br><font color='blue'>Old file in /etc/switchlanplay_list.json-bak</font>"))
uplist.inputstyle = "apply"
uplist.inputtitle = translate("Last date" .. up_time .. " ,Click Update")

function uplist.write(self, section, value)                                                                                   
        sys.call("cp -f /etc/switchlanplay_list.json  /etc/switchlanplay_list.json-bak") 
        sys.call("wget -O- 'http://gpup.top:10240/server/getlist' > /etc/switchlanplay_list.json ")              
        os.execute("sleep " .. 9 )
	luci.http.write("<script>location.href='./switchlanplay';</script>")                                                                                                                                                                          
        return                                                                                                               
end 


return m
