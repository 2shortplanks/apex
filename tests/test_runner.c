/**
 * Apex Test Runner
 * Main test runner that calls all test suites
 */

#include "test_helpers.h"
#include "apex/apex.h"

#include <string.h>

/* Forward declarations */
void test_basic_markdown(void);
void test_gfm_features(void);
void test_metadata(void);
void test_mmd_metadata_keys(void);
void test_metadata_transforms(void);
void test_metadata_control_options(void);
void test_wiki_links(void);
void test_image_embedding(void);
void test_image_width_height_conversion(void);
void test_math(void);
void test_critic_markup(void);
void test_processor_modes(void);
void test_file_includes(void);
void test_ial(void);
void test_bracketed_spans(void);
void test_definition_lists(void);
void test_advanced_tables(void);
void test_relaxed_tables(void);
void test_comprehensive_table_features(void);
void test_combine_gitbook_like(void);
void test_callouts(void);
void test_blockquote_lists(void);
void test_toc(void);
void test_html_markdown_attributes(void);
void test_fenced_divs(void);
void test_sup_sub(void);
void test_mixed_lists(void);
void test_unsafe_mode(void);
void test_abbreviations(void);
void test_mmd6_features(void);
void test_emoji(void);
void test_special_markers(void);
void test_inline_tables(void);
void test_advanced_footnotes(void);
void test_standalone_output(void);
void test_pretty_html(void);
void test_header_ids(void);
void test_indices(void);
void test_citations(void);
void test_aria_labels(void);

/**
 * Main test runner
 */
int main(int argc, char *argv[]) {
    printf("Apex Test Suite v%s\n", apex_version_string());
    printf("==========================================\n");

    if (argc > 1 && argv[1]) {
        // Run only the specified test suite
        if (strcmp(argv[1], "tests_basic") == 0 || strcmp(argv[1], "basic") == 0) {
            test_basic_markdown();
        } else if (strcmp(argv[1], "gfm") == 0) {
            test_gfm_features();
        } else if (strcmp(argv[1], "metadata") == 0) {
            test_metadata();
        } else if (strcmp(argv[1], "metadata_transforms") == 0) {
            test_metadata_transforms();
        } else if (strcmp(argv[1], "mmd_metadata_keys") == 0) {
            test_mmd_metadata_keys();
        } else if (strcmp(argv[1], "metadata_control_options") == 0) {
            test_metadata_control_options();
        } else if (strcmp(argv[1], "wiki_links") == 0) {
            test_wiki_links();
        } else if (strcmp(argv[1], "math") == 0) {
            test_math();
        } else if (strcmp(argv[1], "critic_markup") == 0) {
            test_critic_markup();
        } else if (strcmp(argv[1], "processor_modes") == 0) {
            test_processor_modes();
        } else if (strcmp(argv[1], "file_includes") == 0) {
            test_file_includes();
        } else if (strcmp(argv[1], "ial") == 0) {
            test_ial();
        } else if (strcmp(argv[1], "bracketed_spans") == 0) {
            test_bracketed_spans();
        } else if (strcmp(argv[1], "definition_lists") == 0) {
            test_definition_lists();
        } else if (strcmp(argv[1], "advanced_tables") == 0) {
            test_advanced_tables();
        } else if (strcmp(argv[1], "relaxed_tables") == 0) {
            test_relaxed_tables();
        } else if (strcmp(argv[1], "comprehensive_table_features") == 0) {
            test_comprehensive_table_features();
        } else if (strcmp(argv[1], "combine_gitbook_like") == 0) {
            test_combine_gitbook_like();
        } else if (strcmp(argv[1], "callouts") == 0) {
            test_callouts();
        } else if (strcmp(argv[1], "blockquote_lists") == 0) {
            test_blockquote_lists();
        } else if (strcmp(argv[1], "toc") == 0) {
            test_toc();
        } else if (strcmp(argv[1], "html_markdown_attributes") == 0) {
            test_html_markdown_attributes();
        } else if (strcmp(argv[1], "fenced_divs") == 0) {
            test_fenced_divs();
        } else if (strcmp(argv[1], "sup_sub") == 0) {
            test_sup_sub();
        } else if (strcmp(argv[1], "mixed_lists") == 0) {
            test_mixed_lists();
        } else if (strcmp(argv[1], "unsafe_mode") == 0) {
            test_unsafe_mode();
        } else if (strcmp(argv[1], "abbreviations") == 0) {
            test_abbreviations();
        } else if (strcmp(argv[1], "mmd6_features") == 0) {
            test_mmd6_features();
        } else if (strcmp(argv[1], "emoji") == 0) {
            test_emoji();
        } else if (strcmp(argv[1], "special_markers") == 0) {
            test_special_markers();
        } else if (strcmp(argv[1], "inline_tables") == 0) {
            test_inline_tables();
        } else if (strcmp(argv[1], "advanced_footnotes") == 0) {
            test_advanced_footnotes();
        } else if (strcmp(argv[1], "standalone_output") == 0) {
            test_standalone_output();
        } else if (strcmp(argv[1], "pretty_html") == 0) {
            test_pretty_html();
        } else if (strcmp(argv[1], "header_ids") == 0) {
            test_header_ids();
        } else if (strcmp(argv[1], "image_embedding") == 0) {
            test_image_embedding();
        } else if (strcmp(argv[1], "image_width_height_conversion") == 0) {
            test_image_width_height_conversion();
        } else if (strcmp(argv[1], "indices") == 0) {
            test_indices();
        } else if (strcmp(argv[1], "citations") == 0) {
            test_citations();
        } else if (strcmp(argv[1], "aria_labels") == 0) {
            test_aria_labels();
        } else {
            printf("Unknown test suite: %s\n", argv[1]);
            return 2;
        }
    } else {
        // Run all test suites
        test_basic_markdown();
        test_gfm_features();
        test_metadata();
        test_metadata_transforms();
        test_mmd_metadata_keys();
        test_metadata_control_options();
        test_wiki_links();
        test_math();
        test_critic_markup();
        test_processor_modes();
        test_file_includes();
        test_ial();
        test_bracketed_spans();
        test_definition_lists();
        test_advanced_tables();
        test_relaxed_tables();
        test_comprehensive_table_features();
        test_combine_gitbook_like();
        test_callouts();
        test_blockquote_lists();
        test_toc();
        test_html_markdown_attributes();
        test_fenced_divs();
        test_sup_sub();
        test_mixed_lists();
        test_unsafe_mode();
        test_abbreviations();
        test_mmd6_features();
        test_emoji();
        test_special_markers();
        test_inline_tables();
        test_advanced_footnotes();
        test_standalone_output();
        test_pretty_html();
        test_header_ids();
        test_image_embedding();
        test_image_width_height_conversion();
        test_indices();
        test_citations();
        test_aria_labels();
    }

    /* Print results */
    printf("\n==========================================\n");
    printf("Results: %d total, ", tests_run);
    printf(COLOR_GREEN "%d passed" COLOR_RESET ", ", tests_passed);
    printf(COLOR_RED "%d failed" COLOR_RESET "\n", tests_failed);

    if (tests_failed == 0) {
        printf(COLOR_GREEN "\nAll tests passed! ✓" COLOR_RESET "\n");
        return 0;
    } else {
        printf(COLOR_RED "\nSome tests failed!" COLOR_RESET "\n");
        return 1;
    }
}
