include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-switch-lan-play
PKG_VERSION=0.0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-switch-lan-play
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	DEPENDS:= +switch-lan-play +luci-lib-json
	TITLE:=luci-app-switch-lan-play
	PKGARCH:=all
endef

define Package/luci-app-switch-lan-play/description
	 LuCI web-interface for Switch Lan Play Client
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./* $(PKG_BUILD_DIR)/
endef  

define Build/Compile
endef

define Package/luci-app-switch-lan-play/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/root/etc/config/switchlanplay $(1)/etc/config/switchlanplay

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/root/etc/switchlanplay_list.json $(1)/etc/switchlanplay_list.json

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/switchlanplay $(1)/etc/init.d/switchlanplay


	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/model/cbi/switchlanplay.lua $(1)/usr/lib/lua/luci/model/cbi/switchlanplay.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/root/usr/lib/lua/luci/controller/switchlanplay.lua $(1)/usr/lib/lua/luci/controller/switchlanplay.lua
endef

$(eval $(call BuildPackage,luci-app-switch-lan-play))
