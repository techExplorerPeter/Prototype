
BIN2C_SHELL := ./bin2c.sh
BUILDIN_PRAMA_NAME ?=

CCDEFINES += #-DDATA_BUILDIN

.PHONY: build_in

build_in: prepare_sh  dat2c all

prepare_sh:
	sed -i 's/\r$///' $(BIN2C_SHELL)

dat2c:
	$(eval DBG_CFLAGS += -DDATA_BUILDIN)
	$(eval OPT_CFLAGS += -DDATA_BUILDIN)
	$(BIN2C_SHELL) ./data/in/S32R45/$(BUILDIN_PRAMA_NAME)

# ---use in c sources
# #ifdef DATA_BUILDIN
# #include "data_in_all.h"
# #endif