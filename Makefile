include $(TOPDIR)/rules.mk

PKG_NAME:=freifunk-berlin-autoupdate
PKG_VERSION:=0.7.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/freifunk-berlin-autoupdate/default
  SECTION:=freifunk-berlin
  CATEGORY:=freifunk-berlin
  URL:=http://github.com/freifunk-berlin/packages_berlin
  PKGARCH:=all
endef

define Package/freifunk-berlin-autoupdate
  $(call Package/freifunk-berlin-autoupdate/default)
  TITLE:=Freifunk Berlin Autoupdate
  DEPENDS:=+uci
endef

define Package/freifunk-berlin-autoupdate/description
  autoupdate wants to get the upgrade process of a freifunk-berlin router via terminal smooth and easy.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/freifunk-berlin-autoupdate/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/autoupdate $(1)/usr/bin/autoupdate
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/cfg_autoupdate $(1)/etc/config/autoupdate
	$(INSTALL_DIR) $(1)/usr/share/autoupdate
	$(INSTALL_DATA) ./files/urlencode.sed $(1)/usr/share/autoupdate/urlencode.sed
	$(INSTALL_DIR) $(1)/usr/share/autoupdate
	$(CP) ./files/cert.pub $(1)/usr/share/autoupdate/akira.pub
	$(INSTALL_DIR) $(1)/usr/share/autoupdate
        $(CP) ./files/phrase.pub $(1)/usr/share/autoupdate/akira2.pub
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/config_defaults.sh $(1)/etc/uci-defaults/freifunk-berlin-autoupdate.sh
endef

$(eval $(call BuildPackage,freifunk-berlin-autoupdate))
