cmake_minimum_required (VERSION 3.6.0)

PROJECT(folly CXX)
enable_language(CXX)
set(PACKAGE_NAME      folly)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_EXTENSIONS OFF)

# includes
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})
# function(auto_sources RETURN_VALUE PATTERN SOURCE_SUBDIRS)
#   if ("${SOURCE_SUBDIRS}" STREQUAL "RECURSE")
#     SET(PATH ".")
#     if (${ARGC} EQUAL 4)
#       list(GET ARGV 3 PATH)
#     endif ()
#   endif()

#   if ("${SOURCE_SUBDIRS}" STREQUAL "RECURSE")
#     unset(${RETURN_VALUE})
#     file(GLOB SUBDIR_FILES "${PATH}/${PATTERN}")
#     list(APPEND ${RETURN_VALUE} ${SUBDIR_FILES})

#     file(GLOB subdirs RELATIVE ${PATH} ${PATH}/*)

#     foreach(DIR ${subdirs})
#       if (IS_DIRECTORY ${PATH}/${DIR})
#         if (NOT "${DIR}" STREQUAL "CMakeFiles")
#           file(GLOB_RECURSE SUBDIR_FILES "${PATH}/${DIR}/${PATTERN}")
#           list(APPEND ${RETURN_VALUE} ${SUBDIR_FILES})
#         endif()
#       endif()
#     endforeach()
#   else()
#     file(GLOB ${RETURN_VALUE} "${PATTERN}")

#     foreach (PATH ${SOURCE_SUBDIRS})
#       file(GLOB SUBDIR_FILES "${PATH}/${PATTERN}")
#       list(APPEND ${RETURN_VALUE} ${SUBDIR_FILES})
#     endforeach()
#   endif ()

#   set(${RETURN_VALUE} ${${RETURN_VALUE}} PARENT_SCOPE)
# endfunction(auto_sources)

# function(REMOVE_MATCHES_FROM_LISTS)
#   set(LISTS_TO_SEARCH)
#   set(MATCHES_TO_REMOVE)
#   set(MATCHES_TO_IGNORE)
#   set(argumentState 0)
#   foreach (arg ${ARGN})
#     if ("x${arg}" STREQUAL "xMATCHES")
#       set(argumentState 1)
#     elseif ("x${arg}" STREQUAL "xIGNORE_MATCHES")
#       set(argumentState 2)
#     elseif (argumentState EQUAL 0)
#       list(APPEND LISTS_TO_SEARCH ${arg})
#     elseif (argumentState EQUAL 1)
#       list(APPEND MATCHES_TO_REMOVE ${arg})
#     elseif (argumentState EQUAL 2)
#       list(APPEND MATCHES_TO_IGNORE ${arg})
#     else()
#       message(FATAL_ERROR "Unknown argument state!")
#     endif()
#   endforeach()

#   foreach (theList ${LISTS_TO_SEARCH})
#     foreach (entry ${${theList}})
#       foreach (match ${MATCHES_TO_REMOVE})
#         if (${entry} MATCHES ${match})
#           set(SHOULD_IGNORE OFF)
#           foreach (ign ${MATCHES_TO_IGNORE})
#             if (${entry} MATCHES ${ign})
#               set(SHOULD_IGNORE ON)
#               break()
#             endif()
#           endforeach()

#           if (NOT SHOULD_IGNORE)
#             list(REMOVE_ITEM ${theList} ${entry})
#           endif()
#         endif()
#       endforeach()
#     endforeach()
#     set(${theList} ${${theList}} PARENT_SCOPE)
#   endforeach()
# endfunction()

include(FollyFunctions)

include(FollyConfigChecks)
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/CMake/folly-config.h.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/folly/folly-config.h
)

# set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/../../../..)
# include(${ROOT_DIR}/cmake/setup.cmake)

set(FOLLY_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/folly)
set(FOLLY_DIR ${CMAKE_CURRENT_LIST_DIR}/folly)
list(APPEND dir_list ${FOLLY_SRC_DIR})
list(APPEND dir_list ${FOLLY_SRC_DIR}/lang)
list(APPEND dir_list ${FOLLY_SRC_DIR}/hash/)
list(APPEND dir_list ${FOLLY_SRC_DIR}/detail)
list(APPEND dir_list ${FOLLY_SRC_DIR}/memory/detail)

# list(APPEND dir_list ${BOOST_DIR})
# list(APPEND dir_list ${BOOST_DIR}/../)
# list(APPEND dir_list ${LIBEVENT_DIR}/)
# list(APPEND dir_list ${LIBEVENT_DIR}/include/)
# list(APPEND dir_list ${OPENSSL_DIR}/include/)

include_directories(
  BEFORE
  ${CMAKE_CURRENT_LIST_DIR}
  ${dir_list}
)

set(FLAGS "")
if(ANDROID)
  set(FLAGS "-DFOLLY_HAVE_MEMRCHR")
endif()

add_compile_options(
  -DFOLLY_HAVE_CLOCK_GETTIME=1
  -DFOLLY_HAVE_PTHREAD=1
  -DFOLLY_NO_CONFIG=1
  -DFOLLY_MOBILE=1
  -DFOLLY_USE_LIBCPP=1
  -DFOLLY_HAVE_LIBJEMALLOC=0
  -DFOLLY_HAVE_PREADV=0
  ${FLAGS}
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

if (CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
  add_compile_options(-mpclmul)
endif()

file(GLOB SRC_FILES ${FOLLY_SRC_DIR}/portability/*.cpp
  ${FOLLY_SRC_DIR}/io/async/ssl/*.cpp
  ${FOLLY_SRC_DIR}/io/async/*.cpp
  ${FOLLY_SRC_DIR}/detail/*.cpp
  ${FOLLY_SRC_DIR}/synchronization/*.cpp
  ${FOLLY_SRC_DIR}/lang/*.cpp
  ${FOLLY_SRC_DIR}/hash/*.cpp
  ${FOLLY_SRC_DIR}/hash/detail/*.cpp
  ${FOLLY_SRC_DIR}/memory/*.cpp
  ${FOLLY_SRC_DIR}/futures/*.cpp
  ${FOLLY_SRC_DIR}/futures/detail/*.cpp
  ${FOLLY_SRC_DIR}/experimental/hazptr/*.cpp
  ${FOLLY_SRC_DIR}/executors/*.cpp
  ${FOLLY_SRC_DIR}/concurrency/*.cpp
  ${FOLLY_SRC_DIR}/ssl/*.cpp
  ${FOLLY_SRC_DIR}/ssl/detail/*.cpp
  )
list(APPEND SRC_FILES ${FOLLY_SRC_DIR}/io/async/HHWheelTimer.cpp
  ${FOLLY_SRC_DIR}/io/async/AsyncPipe.cpp
  ${FOLLY_SRC_DIR}/io/async/AsyncTimeout.cpp
  ${FOLLY_SRC_DIR}/io/async/EventBaseManager.cpp
  ${FOLLY_SRC_DIR}/io/async/TimeoutManager.cpp
  ${FOLLY_SRC_DIR}/io/async/AsyncSocketException.cpp
  ${FOLLY_SRC_DIR}/io/async/Request.cpp
  ${FOLLY_SRC_DIR}/io/async/EventBase.cpp
  ${FOLLY_SRC_DIR}/io/async/EventHandler.cpp
  ${FOLLY_SRC_DIR}/io/async/VirtualEventBase.cpp
  ${FOLLY_SRC_DIR}/io/ShutdownSocketSet.cpp
  ${FOLLY_SRC_DIR}/SharedMutex.cpp
  ${FOLLY_SRC_DIR}/ExceptionWrapper.cpp
  ${FOLLY_SRC_DIR}/system/ThreadName.cpp
  ${FOLLY_SRC_DIR}/io/IOBuf.cpp
  ${FOLLY_SRC_DIR}/io/IOBufQueue.cpp
  ${FOLLY_SRC_DIR}/File.cpp
  ${FOLLY_SRC_DIR}/Random.cpp
  ${FOLLY_SRC_DIR}/Singleton.cpp
  ${FOLLY_SRC_DIR}/IPAddress.cpp
  ${FOLLY_SRC_DIR}/IPAddressV4.cpp
  ${FOLLY_SRC_DIR}/IPAddressV6.cpp
  ${FOLLY_SRC_DIR}/MacAddress.cpp
  ${FOLLY_SRC_DIR}/SocketAddress.cpp
  ${FOLLY_SRC_DIR}/Executor.cpp
  ${FOLLY_SRC_DIR}/FileUtil.cpp
  ${FOLLY_SRC_DIR}/lang/ColdClass.cpp
  ${FOLLY_SRC_DIR}/lang/Assume.cpp
  ${FOLLY_SRC_DIR}/json.cpp
  ${FOLLY_SRC_DIR}/Unicode.cpp
  ${FOLLY_SRC_DIR}/Conv.cpp
  ${FOLLY_SRC_DIR}/Demangle.cpp
  ${FOLLY_SRC_DIR}/memory/detail/MallocImpl.cpp
  ${FOLLY_SRC_DIR}/String.cpp
  ${FOLLY_SRC_DIR}/dynamic.cpp
  ${FOLLY_SRC_DIR}/ScopeGuard.cpp
  ${FOLLY_SRC_DIR}/json_pointer.cpp
  ${FOLLY_SRC_DIR}/Format.cpp
  ${FOLLY_SRC_DIR}/String.cpp
  ${FOLLY_SRC_DIR}/memory/detail/MallocImpl.cpp
  )

add_library(${PACKAGE_NAME} STATIC ${SRC_FILES})

#set(build_DIR ${CMAKE_SOURCE_DIR}/build)

#set(libGLOG_BUILD_DIR ${build_DIR}/libglog/${ANDROID_ABI})
#set(doubleconversion_build_DIR ${build_DIR}/doubleconversion/${ANDROID_ABI})
#set(libevent_build_DIR ${build_DIR}/libevent/${ANDROID_ABI})


#file(MAKE_DIRECTORY ${build_DIR})

#add_subdirectory(${GLOG_DIR} ${libGLOG_BUILD_DIR})
#add_subdirectory(${DOUBLECONVERSION_DIR} ${doubleconversion_build_DIR})
#add_subdirectory(${LIBEVENT_DIR} ${libevent_build_DIR})

#target_include_directories(${PACKAGE_NAME} PRIVATE
#  ${OPENSSL_DIR}/include/
#  ${BOOST_DIR}
#  ${BOOST_DIR}/../
#  ${GLOG_DIR}/../
#  ${GLOG_SRC_DIR}/src/
#  ${DOUBLECONVERSION_DIR})


#set(OPENSSL_LINK_DIRECTORIES ${PROJECT_SOURCE_DIR}/../OpenSSL/libs/${ANDROID_ABI}/)
# find_path(OPENSSL_LIBRARY libssl.a)


# SET_NATIVE_OUTPUT_DIRS(${PACKAGE_NAME})

auto_sources(hfiles "*.h" "RECURSE" "${FOLLY_DIR}")
#install(TARGETS ${PACKAGE_NAME}  DESTINATION ./build/)
REMOVE_MATCHES_FROM_LISTS(files hfiles
  MATCHES
    "^${FOLLY_DIR}/build/"
    "^${FOLLY_DIR}/experimental/exception_tracer/"
    "^${FOLLY_DIR}/experimental/hazptr/bench/"
    "^${FOLLY_DIR}/experimental/hazptr/example/"
    "^${FOLLY_DIR}/futures/exercises/"
    "^${FOLLY_DIR}/logging/example/"
    "^${FOLLY_DIR}/(.*/)?test/"
    "^${FOLLY_DIR}/tools/"
    "Benchmark.cpp$"
    "Test.cpp$"
)

list(APPEND hfiles
${CMAKE_CURRENT_BINARY_DIR}/folly/folly-config.h
)
list(REMOVE_ITEM hfiles
  ${FOLLY_DIR}/detail/SlowFingerprint.h
  ${FOLLY_DIR}/detail/FingerprintPolynomial.h
  ${FOLLY_DIR}/python/fibers.h
  ${FOLLY_DIR}/python/GILAwareManualExecutor.h
)
# list(APPEND hfiles
# ${FOLLY_DIR}/io/async/test/AsyncSSLSocketTest.h
# ${FOLLY_DIR}/io/async/test/AsyncSocketTest.h
# ${FOLLY_DIR}/io/async/test/AsyncSocketTest2.h
# ${FOLLY_DIR}/io/async/test/BlockingSocket.h
# ${FOLLY_DIR}/io/async/test/MockAsyncSocket.h
# ${FOLLY_DIR}/io/async/test/MockAsyncServerSocket.h
# ${FOLLY_DIR}/io/async/test/MockAsyncSSLSocket.h
# ${FOLLY_DIR}/io/async/test/MockAsyncTransport.h
# ${FOLLY_DIR}/io/async/test/MockAsyncUDPSocket.h
# ${FOLLY_DIR}/io/async/test/MockTimeoutManager.h
# ${FOLLY_DIR}/io/async/test/ScopedBoundPort.h
# ${FOLLY_DIR}/io/async/test/SocketPair.h
# ${FOLLY_DIR}/io/async/test/TestSSLServer.h
# ${FOLLY_DIR}/io/async/test/TimeUtil.h
# ${FOLLY_DIR}/io/async/test/UndelayedDestruction.h
# ${FOLLY_DIR}/io/async/test/Util.h
# ${FOLLY_DIR}/test/TestUtils.h)

REMOVE_MATCHES_FROM_LISTS(files hfiles
  MATCHES
    "^${FOLLY_DIR}/experimental/symbolizer/"
)

list(REMOVE_ITEM hfiles
  ${FOLLY_DIR}/experimental/RCURefCount.h
  ${FOLLY_DIR}/experimental/RCUUtils.h
)

list(REMOVE_ITEM hfiles
  ${FOLLY_DIR}/experimental/RCURefCount.h
  ${FOLLY_DIR}/experimental/RCUUtils.h
)

list(REMOVE_ITEM hfiles
  ${FOLLY_DIR}/Poly.h
  ${FOLLY_DIR}/Poly-inl.h
  ${FOLLY_DIR}/detail/PolyDetail.h
  ${FOLLY_DIR}/detail/TypeList.h
  ${FOLLY_DIR}/poly/Nullable.h
  ${FOLLY_DIR}/poly/Regular.h
)

target_link_libraries(${PACKAGE_NAME} glog double-conversion ssl crypto event event_extra event_core)

install (TARGETS ${PACKAGE_NAME}
  RUNTIME DESTINATION bin
  PUBLIC_HEADER DESTINATION include
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY folly DESTINATION include FILES_MATCHING PATTERN "*.h")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/folly/folly-config.h DESTINATION include/folly)

# install(
#   FILES ${CMAKE_CURRENT_BINARY_DIR}/folly/folly-config.h
#   DESTINATION ${INCLUDE_INSTALL_DIR}/folly
# )