#!/bin/bash

find . -name "*.h.in" > headers.in.txt
HEADERS=$(cat headers.in.txt)

function updateFile() {
  FILE=${1}
  SEARCH=${2}
  REPLACE=${3}

  # if [[ $(uname) = "Darwin" ]]; then
  sed -i '' -e "s/@${SEARCH}@/${REPLACE}/g" ${FILE}
}

for h in ${HEADERS};do
  updateFile ${h} ac_cv_have_unistd_h 1
  updateFile ${h} ac_cv_have_stdint_h 1
  updateFile ${h} ac_cv_have_systypes_h 1
  updateFile ${h} ac_cv_have_inttypes_h 1
  updateFile ${h} ac_cv_have_libgflags 0
  updateFile ${h} ac_google_start_namespace "namespace google {"
  updateFile ${h} ac_cv_have_uint16_t 1
  updateFile ${h} ac_cv_have_u_int16_t 1
  updateFile ${h} ac_cv_have___uint16 0
  updateFile ${h} ac_google_end_namespace "}"
  updateFile ${h} ac_cv_have___builtin_expect 1
  updateFile ${h} ac_google_namespace google
  updateFile ${h} ac_cv___attribute___noinline "__attribute__ ((noinline))"
  updateFile ${h} ac_cv___attribute___noreturn "__attribute__ ((noreturn))"
  updateFile ${h} ac_cv___attribute___printf_4_5 "__attribute__((__format__ (__printf__, 4, 5)))"

  mv ${FILE} ${FILE/.h.in/.h}
  echo "Configured ${FILE}"
done