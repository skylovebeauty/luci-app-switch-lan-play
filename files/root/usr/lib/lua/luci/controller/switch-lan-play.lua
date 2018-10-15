module("luci.controller.switch-lan-play", package.seeall)

function index()
        entry({"admin", "services", "switch-lan-play"}, cbi("switch-lan-play"), _("Switch-Lan-Play"), 100)
end