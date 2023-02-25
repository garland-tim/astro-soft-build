cmake_minimum_required(VERSION 3.0)
PROJECT(fx3load C)

set(DATA_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/share/usb/")
############# FX3 Load ###############
set(fx3load_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/main.c ${CMAKE_CURRENT_SOURCE_DIR}/ezusb.c)

add_executable(fxload ${fx3load_SRCS})

install(TARGETS fxload RUNTIME DESTINATION sbin)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/a3load.hex DESTINATION ${DATA_INSTALL_DIR})
