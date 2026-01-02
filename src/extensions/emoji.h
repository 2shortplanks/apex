/**
 * GitHub Emoji Extension for Apex
 */

#ifndef APEX_EMOJI_H
#define APEX_EMOJI_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Replace :emoji: patterns with Unicode emoji or image tags
 */
char *apex_replace_emoji(const char *html);

/**
 * Find emoji name from unicode emoji (reverse lookup)
 * @param unicode The unicode emoji string (UTF-8)
 * @param unicode_len Length of the unicode string in bytes
 * @return Emoji name if found, NULL otherwise
 */
const char *apex_find_emoji_name(const char *unicode, size_t unicode_len);

/**
 * Autocorrect emoji names in markdown text
 * Processes :emoji_name: patterns and corrects typos using fuzzy matching
 * @param text The markdown text to process
 * @return New string with corrected emoji names (caller must free), or NULL on error
 */
char *apex_autocorrect_emoji_names(const char *text);

#ifdef __cplusplus
}
#endif

#endif /* APEX_EMOJI_H */

