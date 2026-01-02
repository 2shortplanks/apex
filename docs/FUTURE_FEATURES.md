# Apex - Future Features & Roadmap

**Last Updated**: December 15, 2025 (PM)

## Recently Completed ✅

### Tier 1 Features (All Complete!)
- [x] **Callouts** (Bear/Obsidian/Xcode) - All types with

  collapsible support

- [x] **File Includes** - Marked's `<<[file]`, `<<(code)`,

  `<<{html}` syntax with recursion protection

- [x] **TOC Generation** - HTML (`<!--TOC-->`), MMD

  (`{{TOC}}`), and Kramdown `{:toc}` markers with `.no_toc`
  exclusion

- [x] **Abbreviations** - Full `*[abbr]: definition` support
- [x] **GitHub Emoji** - Expanded to 350+ common emoji
- [x] **Page Breaks** - Both `<!--BREAK-->` and

  `{::pagebreak /}`

- [x] **Autoscroll Pauses** - `<!--PAUSE:X-->` for

  teleprompter

- [x] **End of Block Markers** - Kramdown's `^` separator

### Advanced Features (NEW - December 4, 2025)
- [x] **Kramdown IAL** - Full implementation with ALD

  support, attribute injection in HTML

- [x] **Advanced Footnotes** - Block-level Markdown content

  (paragraphs, code, lists)

- [x] **Advanced Tables** - Colspan, rowspan, and captions

  (postprocessing approach)

- [ ] **Definition Lists** - Foundation complete, needs

  parsing enhancement

## Features to Add

### File Transclusion (MMD Extended)

From: [MultiMarkdown 6 Transclusion Syntax](https://fletcher.github.io/MultiMarkdown-6/syntax/transclusion.html)

**Note:** Apex implements Marked's include syntax (`<<[file]`, `<<(code)`, `<<{html}`). MMD uses different syntax: `{{file}}`

**MultiMarkdown Transclusion Syntax:**

**Basic Transclusion:**
```markdown
{{some_other_file.txt}}

```

**Wildcard Extensions:**
```markdown
{{foo.*}}    # Choose version based on output format (foo.html, foo.tex, etc.)

```

**Metadata Control:**
```markdown
transclude base: .              # Relative to current file
transclude base: folder/        # In subfolder
transclude base: /absolute/path # Absolute path

```

**Features:**

- Recursive transclusion
- Metadata in transcluded files is ignored
- Search path based on parent file directory
- Can override with `transclude base` metadata
- Wildcard extensions choose format-appropriate version

**Current Status in Apex:**

- [x] Implements Marked's syntax: `<<[file.md]`, `<<(code)`,

  `<<{html}`

- [x] Implements MMD syntax: `{{file}}` for MMD mode

  compatibility

- [x] Wildcard support for transclusion:

`{{file.*}}` with preferred extensions (`.html`, `.md`, `.txt`, `.tex`)

General globbing for patterns like `{{*.md}}`, `{{c?de.py}}`, and `{{{intro,part1}.md}}`

- [x] `transclude base` metadata support

**Implementation Estimate:** 1-2 hours
**Complexity:** Medium (mostly extending existing includes
system)

### ~~Advanced Table Syntax~~ ✅ COMPLETE

**Status:** [x] Implemented (December 4, 2025)

**What's Working:**

- ✅ **Colspan** - Empty cells merge with previous cell
- ✅ **Colspan** - `<<` marker for explicit spanning
- ✅ **Rowspan** - `^^` marker merges with cell above

✅ **Table Captions** - `[Caption]` format before/after table

- ✅ **Backward Compatible** - All existing tables work

  perfectly

**Examples:**
```markdown
| Header 1  | Header 2 | Header 3 |
| --------- | -------- | -------- |
| Wide cell |          | Normal   | # colspan with empty cells |
| Row 1     | Data A   | Data X   |
| ^^        | Data B   | Data Y   | # rowspan with ^^          |

[Table 1: Sales Data]                # caption

| Quarter | Revenue |
| ------- | ------- |
| Q1      | $100k   |

```

**Implementation:** Postprocessing extension that detects
span patterns and captions without modifying the core table
parser.

**Future Enhancements (Optional):**

- Multi-line cells with `\\` in header
- Cell background colors via attributes
- More complex table layouts

### Complete GitHub Emoji Support

From: https://gist.github.com/rxaviers/7360908

**Current:** 350+ common emoji ✅
**Target:** 1,800+ complete GitHub emoji set (optional
expansion)

**Popular Categories:**

**Smileys & Emotion:** :smile:, :heart:, :joy:, :cry:, etc.

- **People & Body:** :thumbsup:, :wave:, :clap:, :muscle:,

  etc.

- **Animals & Nature:** :dog:, :cat:, :tree:, :sun:, etc.
- **Food & Drink:** :pizza:, :coffee:, :beer:, :cake:, etc.
- **Travel & Places:** :car:, :airplane:, :house:,

  :flag-us:, etc.

- **Activities:** :soccer:, :basketball:, :guitar:, :art:,

  etc.

- **Objects:** :phone:, :computer:, :book:, :gift:, etc.
- **Symbols:** :heart:, :star:, :check:, :cross:, etc.
- **Flags:** :flag-us:, :flag-gb:, :flag-jp:, etc.

**Implementation Approaches:**

**Option A: Static Map** (Simplest)

- Include all 1,800+ emoji in C array
- ~100KB of emoji data
- No external dependencies
- Fast lookup
- **Estimate:** 2-3 hours (mostly data entry)

**Option B: JSON Database** (Flexible)

- Load emoji from JSON file
- Easier to update
- Smaller binary
- **Estimate:** 3-4 hours

**Option C: External API** (Not recommended)

- Query GitHub API
- Requires network
- Slow
- Not practical for Apex

**Recommendation:** Option A (static map)

### Definition Lists (Foundation Complete)

**Status:** [ ] Foundation implemented, needs parsing
enhancement

Kramdown/PHP Markdown Extra definition lists:

```markdown
Term 1
: Definition 1a
: Definition 1b

Term 2
: Definition 2
  With multiple paragraphs

  And code blocks

      code here

```

**What's Complete:**

- [x] Extension structure created
- [x] Node types registered (`<dl>`, `<dt>`, `<dd>`)
- [x] HTML rendering implemented
- [x] Block containment support

**What's Needed:**

- [ ] Parsing logic to detect `:` lines
- [ ] Convert paragraphs + definitions to proper structure
- [ ] Block-level content parsing in definitions

**Implementation Estimate:** 1-2 hours (for completion)
**Complexity:** Medium (parsing logic)

### ~~Kramdown IAL (Full Implementation)~~ ✅ COMPLETE

**Status:** ✅ Fully implemented (December 4, 2025)

**What's Working:**

**Block IAL:**
```markdown
## Header
{: #custom-id .class1 .class2 key="value"}

Paragraph with attributes.
{: .special}

```

**Output:**
```html
<h1 id="custom-id" class="class1 class2" key="value">Header</h1>
<p class="special">Paragraph with attributes.</p>

```

**Attribute List Definitions (ALD):**
```markdown
{:ref: #id .class key="value"}

## Header
{: ref}

```

**Features Complete:**

- ✅ Parse `{: attributes}` syntax
- ✅ Parse `{:name: attributes}` ALD definitions
- ✅ Store and resolve ALD references
- ✅ Attach attributes to block elements (headers,

  paragraphs, blockquotes)

- ✅ Complex attribute parsing (ID, classes, key-value pairs)
- ✅ Custom HTML renderer injects attributes
- ✅ IAL paragraphs removed from output

**Future Enhancement:**

- Span-level IAL: `*text*{:.class}` (lower priority)

### HTML Markdown Attributes

Parse markdown inside HTML based on `markdown` attribute:

```html
<div markdown="1">
## This markdown is parsed
</div>

<span markdown="span">*emphasis* works</span>

<div markdown="0">
## This is literal, not parsed
</div>

```

**Requirements:**

- Parse HTML tags during preprocessing
- Check for `markdown` attribute
- Selectively enable/disable markdown parsing
- Handle block vs. span contexts
- Complex interaction with HTML parser

**Implementation Estimate:** 3-4 hours
**Complexity:** High

### ~~Advanced Footnote Features~~ ✅ COMPLETE

**Status:** ✅ Fully implemented (December 4, 2025)

**Block-level content in footnotes:**
```markdown
[^1]: Simple footnote.

[^complex]: Footnote with multiple paragraphs.

    Second paragraph with more details.

    ```python

    def example():
        return "code in footnote"
    ```

    - List item one
    - List item two

```

**Features Complete:**

- [x] Detects block-level content patterns (blank lines,

  indentation)

- [x] Re-parses footnote definitions as full Markdown blocks
- [x] Supports multiple paragraphs
- [x] Supports code blocks (fenced and indented)
- [x] Supports lists, blockquotes, and other block elements

[x] Postprocessing approach (no parser modification needed)

- [x] Maintains compatibility with simple footnotes

**Implementation:** Advanced footnotes extension with
postprocessing to enhance cmark-gfm's footnote system.

### ~~Page Breaks & Special Markers~~ ✅ COMPLETE

**Status:** ✅ Implemented

**Page Breaks:**
```markdown
<!--BREAK-->          # [x] Working
{::pagebreak /}       # [x] Working

```

**Autoscroll Pauses:**
```markdown
<!--PAUSE:5-->        # [x] Working

```

Outputs proper HTML with classes and inline styles for
print/PDF compatibility.

### ~~End of Block Marker~~ ✅ COMPLETE

**Status:** ✅ Implemented

Kramdown's block separator:

```markdown
* list one
^
* list two

```

Forces separate lists instead of continuation.

**Implementation:** Part of special_markers extension,
processes `^` character as block separator.

### Pygments Syntax Highlighting

Server-side syntax highlighting using Pygments:

**Requirements:**

- Python Pygments dependency
- Shell out to Pygments
- Cache results
- Handle multiple languages
- Error handling

**Alternative:** client-side (Prism.js, highlight.js)

**Implementation Estimate:** 4-6 hours
**Complexity:** High (external dependency)

## Implementation Priority Recommendations

### Tier 1: High Value, Easy (< 2 hours each) - ✅ ALL COMPLETE!
1. [x] **Callouts** - COMPLETE
2. [x] **File Includes** - COMPLETE
3. [x] **TOC Generation** - COMPLETE
4. [x] **Abbreviations** - COMPLETE
5. [x] **GitHub Emoji** - COMPLETE (350+ emoji)
6. [x] **Page Breaks & Pauses** - COMPLETE
7. [x] **End of Block Markers** - COMPLETE

### Tier 2: High Value, Medium Effort (2-4 hours each)
1. **Expand GitHub Emoji** to full 1,800+ set (currently

   350+) - Optional

2. [ ] **Definition Lists** (foundation complete, needs

   parsing)

3. **MMD File Transclusion** ({{file}} syntax, wildcards,

   ranges) - Future

### Tier 3: Complex Features
1. [x] **Advanced Table Syntax** - COMPLETE (rowspan,

   colspan, captions)

2. [x] **Full Kramdown IAL with ALD** - COMPLETE

[x] **Advanced Footnotes** - COMPLETE (block-level content)

[ ] **HTML Markdown Attributes** - Future (lower priority)

5. [ ] **Pygments Integration** - Probably stick with

   client-side highlighting
