# Notice
before you run the ./build/out/justest you must excute "sudo cp ./build/libs/dynamic/libmodule3.so /usr/lib"

# M7 Platform Demo
Prototype
    ├─Build                             // Build
    ├─Doc                               // Platform documentation management
    │  ├─...                            // 
    │  │  ├─...                         // 
    │  │  └─...                         // 
    │  └─...                            //
    ├─SW                                // software
    │  ├─Bootloader                     // bootloader
    │  │  └─...                         //
    │  ├─BuildEnvironment               // build environment check
    │  ├─Makefiles                      // makefiles
    │  │  ├─...                         // 
    │  │  ├─...                         //
    │  │  ├─...                         //
    │  │  └─...                         //
    │  ├─Cobblestone                    // platform cobblestone
    │  │  ├─EDR                         // 
    │  │  ├─DetMgt                      //
    │  │  ├─Public                      //
    │  │  ├─Fusa                        //
    │  │  ├─NvmManager                  //
    │  │  ├─IPCF                        //
    │  │  └─CAN                         //
    │  ├─OEM                            // OEM, will be replace with different oem, but the name must be named as OEM or fixed to OEM
    │  │  ├─Docs                        // OEM requirements and other files
    │  │  ├─Configuration               // OEM configuration
    │  │  ├─Sources                     // OEM source files
    │  │  └─Others                      // others(including tools)
    │  ├─DSP                            // dsp
    │  ├─startConsole.bat               // run bat script
    │  └─Makefile                       // makefile
    ├─Tools                             // tools
    │  ├─Script                         // python and other scripts
    │  └─...                            //
    └─README.md                         // readme

# Platform Project tips
-   