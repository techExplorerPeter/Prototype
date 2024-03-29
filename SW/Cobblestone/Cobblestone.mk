OBJ_DIR ?= ../Build
CUR_DIR := Cobblestone

# add Cobblestone source file
SRC += $(wildcard Cobblestone/*.c)

# add Cobblestone header file
SRC_INCS += -I$(CUR_DIR) 					\
			-I$(CUR_DIR)/include 			\
			-I$(CUR_DIR)/include/include 	\
			-I$(CUR_DIR)/include/header