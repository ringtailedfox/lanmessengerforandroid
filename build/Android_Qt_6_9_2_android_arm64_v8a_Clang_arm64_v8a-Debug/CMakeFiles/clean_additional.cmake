# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/lanmessenger_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/lanmessenger_autogen.dir/ParseCache.txt"
  "lanmessenger_autogen"
  )
endif()
