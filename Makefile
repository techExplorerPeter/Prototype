RADAR_M7_CORE := SW

.PHONY: all

define run_radar_app
	$(MAKE) -C $(RADAR_M7_CORE) $@
endef

all clean config menuconfig:
	$(call run_radar_app)