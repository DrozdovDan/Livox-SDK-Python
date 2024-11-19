cmake_minimum_required(VERSION 3.0)

project(livox_sdk)

set(CMAKE_CXX_STANDARD 11)

message(STATUS "main project dir: " ${PROJECT_SOURCE_DIR})

if (CMAKE_CROSSCOMPILING)
	set(THREADS_PTHREAD_ARG
		"PLEASE_FILL_OUT-FAILED_TO_RUN"
		CACHE STRING "Result from TRY_RUN" FORCE)
endif()

if (UNIX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif(UNIX)

set(SOURCES
   sdk_core/src/device_discovery.cpp
   sdk_core/src/device_manager.cpp
   sdk_core/src/livox_sdk.cpp
   sdk_core/src/base/io_loop.cpp
   sdk_core/src/base/io_thread.cpp
   sdk_core/src/base/logging.cpp
   sdk_core/src/base/thread_base.cpp
   sdk_core/src/base/multiple_io/multiple_io_base.cpp
   sdk_core/src/base/multiple_io/multiple_io_epoll.cpp
   sdk_core/src/base/multiple_io/multiple_io_kqueue.cpp
   sdk_core/src/base/multiple_io/multiple_io_poll.cpp
   sdk_core/src/base/multiple_io/multiple_io_select.cpp
   sdk_core/src/base/wake_up/unix/wake_up_pipe.cpp
   sdk_core/src/base/network/unix/network_util.cpp
   sdk_core/src/comm/comm_port.cpp
   sdk_core/src/comm/sdk_protocol.cpp
   sdk_core/src/command_handler/command_channel.cpp
   sdk_core/src/command_handler/command_handler.cpp
   sdk_core/src/command_handler/command_impl.cpp
   sdk_core/src/command_handler/hub_command_handler.cpp
   sdk_core/src/command_handler/lidar_command_handler.cpp
   sdk_core/src/data_handler/data_handler.cpp
   sdk_core/src/data_handler/hub_data_handler.cpp
   sdk_core/src/data_handler/lidar_data_handler.cpp
   sdk_core/src/third_party/FastCRC/FastCRCsw.cpp
)

add_library(livox_sdk SHARED ${SOURCES})

target_include_directories(livox_sdk PUBLIC
    sdk_core/include  # Adjust this path as necessary
    sdk_core/src
    sdk_core/include/third_party/spdlog
)

add_subdirectory(sdk_core sdk_core)
add_subdirectory(sample/hub)
add_subdirectory(sample/lidar)
add_subdirectory(sample/hub_lvx_file)
add_subdirectory(sample/lidar_lvx_file)
add_subdirectory(sample_cc/hub)
add_subdirectory(sample_cc/lidar)
add_subdirectory(sample_cc/trouble_shooting)
add_subdirectory(sample_cc/lidar_utc_sync)
