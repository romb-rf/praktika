# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\EisenNotion_tests_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\EisenNotion_tests_autogen.dir\\ParseCache.txt"
  "EisenNotion_tests_autogen"
  "googletest-1.17.0\\googlemock\\CMakeFiles\\gmock_autogen.dir\\AutogenUsed.txt"
  "googletest-1.17.0\\googlemock\\CMakeFiles\\gmock_autogen.dir\\ParseCache.txt"
  "googletest-1.17.0\\googlemock\\CMakeFiles\\gmock_main_autogen.dir\\AutogenUsed.txt"
  "googletest-1.17.0\\googlemock\\CMakeFiles\\gmock_main_autogen.dir\\ParseCache.txt"
  "googletest-1.17.0\\googlemock\\gmock_autogen"
  "googletest-1.17.0\\googlemock\\gmock_main_autogen"
  "googletest-1.17.0\\googletest\\CMakeFiles\\gtest_autogen.dir\\AutogenUsed.txt"
  "googletest-1.17.0\\googletest\\CMakeFiles\\gtest_autogen.dir\\ParseCache.txt"
  "googletest-1.17.0\\googletest\\CMakeFiles\\gtest_main_autogen.dir\\AutogenUsed.txt"
  "googletest-1.17.0\\googletest\\CMakeFiles\\gtest_main_autogen.dir\\ParseCache.txt"
  "googletest-1.17.0\\googletest\\gtest_autogen"
  "googletest-1.17.0\\googletest\\gtest_main_autogen"
  )
endif()
