cmake_minimum_required (VERSION 3.6.0)

PROJECT(glog CXX)
enable_language(CXX)
set(PACKAGE_NAME      glog)


set(GLOG_SRC_DIR ${CMAKE_CURRENT_LIST_DIR})
list(APPEND dir_list ./../)
list(APPEND dir_list ./)
list(APPEND dir_list ${GLOG_SRC_DIR}/)
list(APPEND dir_list ${GLOG_SRC_DIR}/src)
list(APPEND dir_list ${GLOG_SRC_DIR}/glog)
list(APPEND dir_list ${GLOG_SRC_DIR}/base)

include_directories(
  BEFORE 
  ${dir_list}
)

add_compile_options(
  -std=c++11
  -Wno-macro-redefined
  -Wno-macro-redefined
  -Wall
  -Wwrite-strings
  -Woverloaded-virtual
  -Wno-sign-compare
  -DNDEBUG
  -g
  -O2
  -D_START_GOOGLE_NAMESPACE_="namespace google {"
  -D_END_GOOGLE_NAMESPACE_="}"
)


set (GLOG_PUBLIC_H
  ${GLOG_SRC_DIR}/src/config.h
  ${GLOG_SRC_DIR}/src/glog/logging.h
   ${GLOG_SRC_DIR}/src/glog/raw_logging.h
   ${GLOG_SRC_DIR}/src/glog/stl_logging.h
   ${GLOG_SRC_DIR}/src/glog/vlog_is_on.h
  ${GLOG_SRC_DIR}/src/glog/log_severity.h
)

list(APPEND src_files 
  ${GLOG_PUBLIC_H}
  ${GLOG_SRC_DIR}/src/demangle.cc
  ${GLOG_SRC_DIR}/src/logging.cc
  ${GLOG_SRC_DIR}/src/raw_logging.cc
  ${GLOG_SRC_DIR}/src/signalhandler.cc
  ${GLOG_SRC_DIR}/src/symbolize.cc
  ${GLOG_SRC_DIR}/src/utilities.cc
  ${GLOG_SRC_DIR}/src/vlog_is_on.cc
  )

add_library(${PACKAGE_NAME} STATIC ${src_files})

set_target_properties (${PACKAGE_NAME} PROPERTIES PUBLIC_HEADER "${GLOG_PUBLIC_H}")

# SET_NATIVE_OUTPUT_DIRS(${PACKAGE_NAME})

#install(TARGETS ${PACKAGE_NAME}  DESTINATION ./build/)
target_link_libraries(${PACKAGE_NAME})

set (CMAKE_CXX_VISIBILITY_PRESET default)
set (CMAKE_VISIBILITY_INLINES_HIDDEN 1)



# install(TARGETS ${PACKAGE_NAME} DESTINATION lib)
install (TARGETS ${PACKAGE_NAME}
  RUNTIME DESTINATION bin
  PUBLIC_HEADER DESTINATION include/glog
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(FILES ${GLOG_PUBLIC_H} DESTINATION include)