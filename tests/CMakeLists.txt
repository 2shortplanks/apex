cmake_minimum_required(VERSION 3.10)

# Test runner
add_executable(test_runner test_runner.c)
target_link_libraries(test_runner apex)
target_compile_definitions(test_runner PRIVATE TEST_FIXTURES_DIR="${CMAKE_CURRENT_SOURCE_DIR}/fixtures/includes")

# Add tests
add_test(NAME basic_tests COMMAND test_runner)

# Example test files
configure_file(test_basic.md test_basic.md COPYONLY)

