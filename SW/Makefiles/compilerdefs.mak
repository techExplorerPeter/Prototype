#do not use directly, meant to be included in a Makefile
#
# Following variables represent inputs (error is fired if they are not set a-priori):
#  PLATFORM (one of S32R45, S32R274, S32R372, S32R294)
#  TARGET (one of z4, z7 for S32R274, a53 for S32R45)
#  COMPILER (one of gcc, diab)
#  OS: one of "sa" (for stand-alone, or no OS) or "linux"
#
# Following variables also represent inputs - defined with ?= so that can be overwritten from invocation command line:
#  EXE_PATH: system root path for finding the toolchain executables
#  TOOL_PATH: root path for constructing command-line toolchain arguments (can be different than EXE_PATH)
#  DS_BINPATH (cross-compiler-bin Design Studio folder)
#  CPU_TOOLCHAIN_BINPATH (cross-compiler-bin folder)
#  DIAB_BINPATH (win32-bin WindRiver compiler folder)
#  LAX_TOOLCHAIN_PATH (cross-compiler-LAX DS folder)
#
# Following variables represent outputs (later on, add to them using +=):
#  ARTIFACT_SUFFIX
#  CC, CFLAGS (gets a #define for PLATFORM), OPT_CFLAGS, DBG_CFLAGS - limitation: not used by any of LAX makefiles
#  AR, ARFLAGS - limitation: not used by any of LAX makefiles
#  SPTASM, SPTPREPROC, SPTPREPROCFLAGS, SPTASMFLAGS (gets a symbol for PLATFORM), SPTOPT_ASMFLAGS, SPTDBG_ASMFLAGS - SPT kernel build specific

#for sinpro
PLATFORM=S32R45
TARGET=a53
COMPILER=gcc
OSENV=linux


#helper functions

#invoke with one param: name of linker command file
define LNK_FILECMD
$(if $(filter $(COMPILER),gcc), \
  -T $(1), \
  $(if $(filter $(COMPILER),diab), \
    $(1), \
    ERROR: LNK_FILECMD NOT DEFINED for this COMPILER \
  )\
)
endef

#invoke with one param: name of map file
define LNK_MAPCMD
$(if $(filter $(COMPILER),gcc), \
  -Xlinker -Map=$(1), \
  $(if $(filter $(COMPILER),diab), \
    -m6 -@O=$(1), \
    ERROR: LNK_FILECMD NOT DEFINED for this COMPILER \
  )\
)
endef

EXE_PATH ?= C:
TOOL_PATH ?= C:

CFLAGS += -D$(PLATFORM) -std=c99 -Wall -fmessage-length=0 -ffunction-sections -fdata-sections -fvisibility=hidden -fsigned-char \
		   -Werror=implicit-function-declaration -fstrict-volatile-bitfields
OPT_CFLAGS := -O3 
DBG_CFLAGS := -O0 -g3

SPTPREPROCFLAGS := -D$(PLATFORM)
SPTASMFLAGS := --defsym $(PLATFORM)=1
SPTOPT_ASMFLAGS :=
SPTDBG_ASMFLAGS :=

ifndef PLATFORM
$(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with PLATFORM = S32R45 or S32R41 or SAF85XX or S32R274 or S32R372)
endif

ifndef TARGET
$(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with TARGET = one of z4, z7 for S32R274, a53 for S32R45, S32R41 and SAF85XX)
endif

ifndef COMPILER
$(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with COMPILER=gcc or diab or linaro)
endif

ifndef OSENV
$(info Building with OSENV=sa)
OSENV := sa
ifeq ($(PLATFORM),S32R45)
$(info OSENV alternatives are: sa, linux)
endif
ifeq ($(PLATFORM),S32R41)
$(info OSENV alternatives are: sa, zephyr)
endif
ifeq ($(PLATFORM),SAF85XX)
$(info OSENV alternatives are: sa, zephyr)
endif
endif

#ifeq ($(PLATFORM),S32R45)
ifeq ($(PLATFORM), $(filter $(PLATFORM), S32R45 S32R41 SAF85XX )) #any of S32R45/S32R41/SAF85XX

    #guard against unsupported configurations:
    ifneq ($(TARGET), a53)
    	$(error For PLATFORM=S32R45 or S32R41 must define TARGET=a53)
    endif

    ifneq ($(COMPILER), gcc)
    	$(error For PLATFORM=S32R45 or S32R41 must define COMPILER=gcc)
    endif

    ifeq ($(PLATFORM),S32R45)
    	ifneq ($(OSENV), $(filter $(OSENV), sa linux ))
    		$(error For PLATFORM=S32R45 must define OSENV=sa|linux)
    	endif
    endif
    
    ifeq ($(PLATFORM),S32R41)
    	ifneq ($(OSENV), $(filter $(OSENV), sa zephyr ))
    		$(error For PLATFORM=S32R41 must define OSENV=sa|zephyr)
    	endif
    endif

    ifeq ($(PLATFORM),SAF85XX)
    	ifneq ($(OSENV), $(filter $(OSENV), sa zephyr ))
    		$(error For PLATFORM=SAF85XX must define OSENV=sa|zephyr)
    	endif
    endif

    #ARM A53
    DS_BINPATH ?= /NXP/S32DS.3.4/S32DS/build_tools
    SPTASMFLAGS += -a64
    ifeq ($(PLATFORM),S32R45)
        SPTASMFLAGS += -I$(TOOL_PATH)$(DS_BINPATH)/SPT3/inc
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/SPT3/bin/as-spt.exe
    	SPTPREPROC := $(EXE_PATH)$(DS_BINPATH)/gcc_v10.2/gcc-10.2-arm64-linux/bin/aarch64-linux-gnu-cpp.exe
    	BBE32_TOOLCHAIN_PATH := $(EXE_PATH)$(DS_BINPATH)/BBE32/tools/RI-2021.7-win32/XtensaTools/bin/
    else ifeq ($(PLATFORM),S32R41)
        SPTASMFLAGS += -I$(TOOL_PATH)$(DS_BINPATH)/SPT3.5/inc
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/SPT3.5/bin/as-spt.exe
        SPTPREPROC := $(EXE_PATH)$(DS_BINPATH)/gcc_v9.2/gcc-9.2-arm64-eabi/bin/aarch64-none-elf-cpp.exe
    	BBE32_TOOLCHAIN_PATH := $(EXE_PATH)$(DS_BINPATH)/BBE32/tools/RI-2021.7-win32/XtensaTools/bin/
    else ifeq ($(PLATFORM),SAF85XX)
        SPTASMFLAGS += -I$(TOOL_PATH)$(DS_BINPATH)/SPT3.4/inc
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/SPT3.4/bin/as-spt.exe
        SPTPREPROC := $(EXE_PATH)$(DS_BINPATH)/gcc_v9.2/gcc-9.2-arm64-eabi/bin/aarch64-none-elf-cpp.exe
    	BBE32_TOOLCHAIN_PATH := $(EXE_PATH)$(DS_BINPATH)/BBE32/tools/RI-2021.7-win32/XtensaTools/bin/
    endif
    ARFLAGS :=
    LAX_TOOLCHAIN_PATH ?= $(EXE_PATH)/NXP/S32DS.3.4/S32DS/build_tools/LAX

	ifeq ($(OSENV),sa) #build for stand-alone (bare metal) environment
		CPU_TOOLCHAIN_BINPATH ?= $(EXE_PATH)$(DS_BINPATH)/gcc_v10.2/gcc-10.2-arm64-eabi/bin/aarch64-none-elf-

        CC := $(CPU_TOOLCHAIN_BINPATH)gcc
        LD := $(CPU_TOOLCHAIN_BINPATH)gcc
        AR := $(CPU_TOOLCHAIN_BINPATH)ar
	    ASM := $(CPU_TOOLCHAIN_BINPATH)gcc
		ifneq ($(filter %Microsoft MINGW% MSYS% %Cygwin, $(shell uname -a)), )
            CC := $(CC).exe
            LD := $(LD).exe
            AR := $(AR).exe
            ASM := $(ASM).exe
        endif
        CFLAGS += -march=armv8-a -mcpu=cortex-a53 -mtune=cortex-a53 -mstrict-align
	else ifeq ($(OSENV), zephyr)
		CPU_TOOLCHAIN_BINPATH ?= $(EXE_PATH)$(DS_BINPATH)/gcc_v9.2/gcc-9.2-arm64-eabi/bin/aarch64-none-elf-
        AR := $(CPU_TOOLCHAIN_BINPATH)ar
		ifneq ($(filter %Microsoft MINGW% MSYS% %Cygwin, $(shell uname -a)), )
            AR := $(AR).exe
        endif
	else #build for linux user space
		KERNEL_DIR ?= /mnt/disk1/repos/fsl-auto-yocto-bsp/build_s32r45xsim/tmp/work/s32r45xsim-fsl-linux/linux-s32/4.19-r0/build
        # the below flags are necessary for WCS report; please don't remove it at least for releases
        CFLAGS += -fstack-usage -fdump-rtl-dfinish 
        
        UNAME_A := $(shell uname -a)
		ifneq ($(filter %Microsoft MINGW% MSYS% %Cygwin, $(UNAME_A)),)
			CPU_TOOLCHAIN_BINPATH ?= $(EXE_PATH)$(DS_BINPATH)/gcc_v10.2/gcc-10.2-arm64-linux/bin/aarch64-linux-gnu-
			CC := $(CPU_TOOLCHAIN_BINPATH)gcc.exe
			CPP := $(CPU_TOOLCHAIN_BINPATH)g++.exe
			LD := $(CPU_TOOLCHAIN_BINPATH)gcc.exe
			LDPP := $(CPU_TOOLCHAIN_BINPATH)g++.exe
			ASM := $(CPU_TOOLCHAIN_BINPATH)gcc.exe
			ASMPP := $(CPU_TOOLCHAIN_BINPATH)g++.exe
			AR := $(CPU_TOOLCHAIN_BINPATH)ar.exe
		else
			CPU_TOOLCHAIN_BINPATH ?= $(CROSS_COMPLIER_PATH)
			CC := $(CPU_TOOLCHAIN_BINPATH)gcc
			CPP := $(CPU_TOOLCHAIN_BINPATH)g++		
			LD := $(CPU_TOOLCHAIN_BINPATH)gcc
			LDPP := $(CPU_TOOLCHAIN_BINPATH)g++
			ASM := $(CPU_TOOLCHAIN_BINPATH)gcc
			ASMPP := $(CPU_TOOLCHAIN_BINPATH)g++
			AR := $(CPU_TOOLCHAIN_BINPATH)ar
		endif

		export CPU_TOOLCHAIN_BINPATH
        export CC
	endif
	
	ifneq ($(filter %Microsoft MINGW% MSYS% %Cygwin, $(shell uname -a)), )
		LAXAR := $(LAX_TOOLCHAIN_PATH)/bin/it3a-ar.exe
		LAXCC := $(LAX_TOOLCHAIN_PATH)/bin/laxcc.exe
		BBE32CC := $(BBE32_TOOLCHAIN_PATH)/xt-clang.exe
		BBE32AR := $(BBE32_TOOLCHAIN_PATH)/xt-ar.exe
		BBE32LD := $(BBE32_TOOLCHAIN_PATH)/xt-clang.exe
	else
		LAXAR := $(LAX_TOOLCHAIN_PATH)/bin/it3a-ar
		LAXCC := $(LAX_TOOLCHAIN_PATH)/bin/laxcc
		BBE32CC := $(BBE32_TOOLCHAIN_PATH)/xt-clang
		BBE32AR := $(BBE32_TOOLCHAIN_PATH)/xt-ar
		BBE32LD := $(BBE32_TOOLCHAIN_PATH)/xt-clang.exe
	endif

	export LAX_TOOLCHAIN_PATH
	export LAXAR
	export LAXCC

else #PLATFORM is not S32R45

  ifeq ($(PLATFORM), $(filter $(PLATFORM), S32R274 S32R372 S32R294)) #any of S32R274/S32R372 or S32R294
    #PPC e200
	ifneq ($(TARGET), $(filter $(TARGET), z4 z7))
      $(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with TARGET=z4|z7)
    endif #TARGET is not a53
    DS_BINPATH ?= /NXP/S32DS_Power_v2.1/S32DS/build_tools/powerpc-eabivle-4_9/bin
    ifeq ($(COMPILER),diab)
      DIAB_BINPATH ?= /WindRiver59/compilers/diab-5.9.6.7/WIN32/bin
      CC := $(EXE_PATH)$(DIAB_BINPATH)/dcc.exe
	  #override these three CFLAGS
      # -XO : Enable all standard optimizations plus the following:
      # -O (see -O)
      # -Xinline=40 (10 with -O;)
      # -Xopt-count=2 (1 with -O;)
      # -Xparse-count=count (Default count is 600,000, or 300,000 with -O; )
      # -Xrestart (off with -O;)
      # -Xtest-at-both (-Xtest-at-bottom with -O;)
	  OPT_CFLAGS := -XO -Xsize-opt
	  #override the DBG CFLAGS
      #    -O0 has a different meaning in diab and it's generating wrong code in some cases, 
      #    replaced -g3 with -g2 as it's the recommended setting
	  DBG_CFLAGS := -g2 -fstrict-volatile-bitfields

	  CFLAGS += -Xdialect-c99 \
                -Xno-common \
                -Xforce-declarations \
                -Xnested-interrupts \
				-Xsection-split \
			    -Xkill-opt=0x80000\
				-Xclib-optim-off\
				-Xstmw-fast\
				-Xlint=0x10\
				-Xaddr-sconst=0x41\
				-Xkeywords=0x1F\
				-Xforce-declarations\
				-Xforce-prototypes\
				-Xpass-source\
				-Xnested-interrupts\
				-Xsmall-data=0\
				-Xsmall-const=0\
				-Xinline=0\
				-Xinline-explicit-force\
				-Xlocal-struct=0\
				-ei1606\
				-ei1824\
				-Xintc-eoir=0\
				-Xstrings-in-text\
				-Xmin-align=4\
				-Xparse-size=10000000\
				-Xunroll=4\
				-Xunroll-size=100 \
				-Xlibc-new \

				#-Wa,-Xisa-vle \
                #-Xmacro-undefined-warn \
                #-ee1481 \
                #-Xc-new \
                #-Xlink-time-lint \
				#-W:as

      ifeq ($(TARGET),z4)
	    CFLAGS += -D__PPCE200Z4__
	  else
	    ifeq ($(TARGET),z7)
	      CFLAGS += -D__PPCE200Z7__
		else
		  Hmmm, target not z4, target not z7, what could it be, then?
		endif
	  endif
      ASM := $(EXE_PATH)$(DIAB_BINPATH)/dcc.exe
      ASM_FLAGS := -c \
                -Wa,-Xisa-vle \
                -Xsemi-is-newline \
				-W:pas:.S $(CFLAGS)
#               -Wa,-Xasm-debug-on \
#                -Xdebug-dwarf2 \

	  LD := $(EXE_PATH)$(DIAB_BINPATH)/dld.exe
      LDFLAGS := -Xelf \
				 -liold -lchar -lc -lcfpold \
				-Xremove-unused-sections \
				-Xcheck-overlapping \
				-Xpreprocess-lecl \
				-Xstack-usage=0x4 \
				-Xlibc-new

				#-Xdont-die
				#-Xlink-time-lint
				#-Xlibc-old
      ifeq ($(TARGET),z4)
        #build for z4 core
        # processor              - PPCE200Z420N3V
        # object module format   - F (PowerPC No Small-Data ELF EABI Object Format)
        # floating point support - F (Single Hardware, Double Software Floating Point)
        # execution environment  - simple (simple - Only character I/O)
        CFLAGS +=    -tPPCE200Z420N3VFF:simple
		ASM_FLAGS += -tPPCE200Z420N3VFF:simple
		LDFLAGS +=   -tPPCE200Z420N3VFF:simple
		#PPCE200Z420N3VEN:simple
      else
      #build for z7 core
        CFLAGS += -tPPCE200Z7260N3VFF:simple
		ASM_FLAGS += -tPPCE200Z7260N3VFF:simple
		LDFLAGS += -tPPCE200Z7260N3VFF:simple
      endif
      AR := $(EXE_PATH)$(DIAB_BINPATH)/dar.exe
      ARFLAGS :=
    else #($(COMPILER),diab)
      ifeq ($(COMPILER),gcc)
        CC := $(EXE_PATH)$(DS_BINPATH)/powerpc-eabivle-gcc.exe
        CFLAGS += -mbig -mvle -mregnames -mhard-float -fstack-usage -fdump-rtl-dfinish
		ASM := $(EXE_PATH)$(DS_BINPATH)/powerpc-eabivle-gcc.exe
		ASM_FLAGS := -x assembler-with-cpp -c $(CFLAGS)
		AR := $(EXE_PATH)$(DS_BINPATH)/powerpc-eabivle-ar.exe
        ARFLAGS :=
		LD := $(EXE_PATH)$(DS_BINPATH)/powerpc-eabivle-gcc.exe
		LDFLAGS := -Xlinker --gc-sections -Xlinker --start-group -mhard-float
        ifeq ($(TARGET),z4)
          #build for z4 core
          CFLAGS += -mcpu=e200z4
		  LDFLAGS += -mcpu=e200z4
        else
          #build for z7 core
          CFLAGS += -mcpu=e200z7
		  LDFLAGS += -mcpu=e200z7
        endif #Z4 target
      else
        $(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with COMPILER=gcc|diab)
      endif #gcc compiler
    endif #diab compiler
    ifeq ($(PLATFORM), S32R274)
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/../../SPT2/bin/as-spt.exe
        SPTASMFLAGS +=  -I$(TOOL_PATH)$(DS_BINPATH)/../../SPT2/inc
	else ifeq ($(PLATFORM), S32R294)
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/../../SPT2.8/bin/as-spt.exe
        SPTASMFLAGS +=  -I$(TOOL_PATH)$(DS_BINPATH)/../../SPT2.8/inc
    else
        SPTASM := $(EXE_PATH)$(DS_BINPATH)/../../SPT2.5/bin/as-spt.exe
        SPTASMFLAGS +=  -I$(TOOL_PATH)$(DS_BINPATH)/../../SPT2.5/inc
    endif # S32R274
    SPTPREPROC := $(EXE_PATH)$(DS_BINPATH)/powerpc-eabivle-cpp.exe
  else #PLATFORM is not S32R274/S32R372/S32R294
    $(error Invoke $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)) with PLATFORM=S32R45|S32R274|S32R372|S32R294)
  endif #PLATFORM is not S32R274/S32R372/S32R294

endif #PLATFORM is not S32R45

ifeq ($(PLATFORM),S32R372)
    ARTIFACT_SUFFIX := $(OSENV)_$(COMPILER)_$(PLATFORM)
else
	ARTIFACT_SUFFIX := $(OSENV)_$(COMPILER)_$(PLATFORM)_$(TARGET)
endif

export DS_BINPATH
