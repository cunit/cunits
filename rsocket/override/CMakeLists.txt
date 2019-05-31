cmake_minimum_required (VERSION 3.6.0)

PROJECT(rsocket CXX)
set(PACKAGE_NAME      rsocket)
set(RSOCKET_VERSION 0.10.3)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)

set(RSOCKET_DIR ${CMAKE_CURRENT_LIST_DIR}/rsocket)
list(APPEND dir_list ${CMAKE_CURRENT_LIST_DIR}/)
list(APPEND dir_list ${RSOCKET_DIR}/)
list(APPEND dir_list ${RSOCKET_DIR}/framing)
list(APPEND dir_list ${RSOCKET_DIR}/internal)
list(APPEND dir_list ${RSOCKET_DIR}/statemachine)
list(APPEND dir_list ${RSOCKET_DIR}/transports)
list(APPEND dir_list ${RSOCKET_DIR}/transports/tcp)
list(APPEND dir_list ${RSOCKET_ROOT_DIR}/yarpl/flowable)
list(APPEND dir_list ${RSOCKET_ROOT_DIR}/yarpl/observable)
list(APPEND dir_list ${RSOCKET_ROOT_DIR}/yarpl/utils)

file(GLOB SRC_FILES ${RSOCKET_DIR}/*.cpp
  ${RSOCKET_DIR}/internal/*.cpp
  ${RSOCKET_DIR}/framing/*.cpp
  ${RSOCKET_DIR}/statemachine/*.cpp
  ${RSOCKET_DIR}/transports/*.cpp
  ${RSOCKET_DIR}/transports/tcp/*.cpp
  ${RSOCKET_ROOT_DIR}/yarpl/observable/*.cpp
  ${RSOCKET_ROOT_DIR}/yarpl/flowable/*.cpp
  ${RSOCKET_ROOT_DIR}/yarpl/utils/*.cpp
  )

include_directories(
  ${dir_list}
  BEFORE

)
set(FLAGS "")
if(ANDROID)
  set(FLAGS "-DFOLLY_HAVE_MEMRCHR")
endif()

add_compile_options(
  -DFOLLY_HAVE_CLOCK_GETTIME=1
  -DFOLLY_HAVE_PTHREAD=1
  -DFOLLY_NO_CONFIG=1
  ${FLAGS}
  -DFOLLY_MOBILE=1
  -DFOLLY_USE_LIBCPP=1
  -DFOLLY_HAVE_LIBJEMALLOC=0
  -DFOLLY_HAVE_PREADV=0
  -frtti
  -fexceptions
  -Wno-error
  -Wno-unused-local-typedefs
  -Wno-unused-variable
  -Wno-sign-compare
  -Wno-comment
  -Wno-return-type
  -Wno-tautological-constant-compare
)

add_library(${PACKAGE_NAME} STATIC ${SRC_FILES})


install (TARGETS ${PACKAGE_NAME}
  RUNTIME DESTINATION bin
  PUBLIC_HEADER DESTINATION include
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY rsocket DESTINATION include FILES_MATCHING PATTERN "*.h")
install(DIRECTORY yarpl DESTINATION include FILES_MATCHING PATTERN "*.h")
# SET_NATIVE_OUTPUT_DIRS(${PACKAGE_NAME})

#target_include_directories(${PACKAGE_NAME} PRIVATE
#        ${LIBFOLLY_DIR}
#        ${BOOST_DIR}
#        ${BOOST_DIR}/../
#        ${LIBEVENT_DIR}/
#        ${LIBEVENT_DIR}/include/
#        ${LIBEVENT_DIR}/include/event2
#        ${OPENSSL_DIR}/include/
#        ${GLOG_DIR}
#        ${GLOG_DIR}/../
#        ${GLOG_DIR}/glog-0.3.5/src/
#    )


# find_path(OPENSSL_LIBRARY libssl.a HINTS ${OPENSSL_LINK_DIRECTORIES})
target_link_libraries(${PACKAGE_NAME}  folly glog double-conversion log event ssl crypto)
