/**
 * Test Helper Functions Implementation
 */

#include "test_helpers.h"
#include <string.h>

/* Test statistics (shared across all test files) */
int tests_run = 0;
int tests_passed = 0;
int tests_failed = 0;

/**
 * Assert that string contains substring
 */
bool assert_contains(const char *haystack, const char *needle, const char *test_name) {
    tests_run++;

    if (strstr(haystack, needle) != NULL) {
        tests_passed++;
        printf(COLOR_GREEN "✓" COLOR_RESET " %s\n", test_name);
        return true;
    } else {
        tests_failed++;
        printf(COLOR_RED "✗" COLOR_RESET " %s\n", test_name);
        printf("  Looking for: %s\n", needle);
        printf("  In:          %s\n", haystack);
        return false;
    }
}

/**
 * Assert that string does NOT contain substring
 */
bool assert_not_contains(const char *haystack, const char *needle, const char *test_name) {
    tests_run++;

    if (strstr(haystack, needle) == NULL) {
        tests_passed++;
        printf(COLOR_GREEN "✓" COLOR_RESET " %s\n", test_name);
        return true;
    } else {
        tests_failed++;
        printf(COLOR_RED "✗" COLOR_RESET " %s\n", test_name);
        printf("  Should NOT contain: %s\n", needle);
        printf("  But found in:        %s\n", haystack);
        return false;
    }
}

/**
 * Assert that a boolean option is set correctly
 */
bool assert_option_bool(bool actual, bool expected, const char *test_name) {
    tests_run++;
    if (actual == expected) {
        tests_passed++;
        printf(COLOR_GREEN "✓" COLOR_RESET " %s\n", test_name);
        return true;
    } else {
        tests_failed++;
        printf(COLOR_RED "✗" COLOR_RESET " %s\n", test_name);
        printf("  Expected: %s, Got: %s\n", expected ? "true" : "false", actual ? "true" : "false");
        return false;
    }
}

/**
 * Assert that a string option matches
 */
bool assert_option_string(const char *actual, const char *expected, const char *test_name) {
    tests_run++;
    if (actual && expected && strcmp(actual, expected) == 0) {
        tests_passed++;
        printf(COLOR_GREEN "✓" COLOR_RESET " %s\n", test_name);
        return true;
    } else {
        tests_failed++;
        printf(COLOR_RED "✗" COLOR_RESET " %s\n", test_name);
        printf("  Expected: %s, Got: %s\n", expected ? expected : "(null)", actual ? actual : "(null)");
        return false;
    }
}

