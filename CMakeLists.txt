
  
# Set the minimum version of CMake that can be used
# To find the cmake version run
# $ cmake --version
set(CMAKE_BUILD_TYPE Debug)
# cmake_minimum_required(VERSION 3.5)


# Set the project name
project (hello_headers)

# Create a sources variable with a link to all cpp files to compile
# set(SOURCES
#     src/finalValueAfterOperations.c
#     src/main.c
# )

# Add an executable with the above sources
# add_executable(hello_headers ${SOURCES})

# Set the directories that should be included in the build command for this target
# when running g++ these will be included as -I/directory/path/
# target_include_directories(hello_headers
#     PRIVATE 
#         ${PROJECT_SOURCE_DIR}/include
# )


# target_include_directories(hello_headers PUBLIC
#                           "${PROJECT_BINARY_DIR}"
#                           "${PROJECT_SOURCE_DIR}/tasks/2_twoSum"
#                           tasks/2_twoSum
#                           )


add_subdirectory(main)
# add_subdirectory(sublibrary2)
# add_subdirectory(subbinary)

                          
add_subdirectory(tasks/2_twoSum)

add_subdirectory(tasks/2011_finalValueAfterOperations)