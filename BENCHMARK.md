# Apex Markdown Processor - Performance Benchmark

## Test Document

- **File:** `/Users/ttscoff/Desktop/Code/apex/tests/fixtures/comprehensive_test.md`
- **Lines:**      619
- **Words:**     2581
- **Size:**    17008 bytes

## Output Modes

| Mode | Iterations | Average (ms) | Min (ms) | Max (ms) | Throughput (words/sec) |
|------|------------|--------------|---------|---------|------------------------|
| Fragment Mode (default HTML output) | 50 | 27 | 21 | 94 | 129050.00 |
| Pretty-Print Mode (formatted HTML) | 50 | 24 | 21 | 89 | 129050.00 |
| Standalone Mode (complete HTML document) | 50 | 30 | 21 | 99 | 86033.33 |
| Standalone + Pretty (full features) | 50 | 30 | 22 | 94 | 86033.33 |

## Mode Comparison

| Mode | Iterations | Average (ms) | Min (ms) | Max (ms) | Throughput (words/sec) |
|------|------------|--------------|---------|---------|------------------------|
| CommonMark Mode (minimal, spec-compliant) | 50 | 16 | 10 | 85 | 258100.00 |
| GFM Mode (GitHub Flavored Markdown) | 50 | 30 | 20 | 104 | 86033.33 |
| MultiMarkdown Mode (metadata, footnotes, tables) | 50 | 30 | 21 | 88 | 86033.33 |
| Kramdown Mode (attributes, definition lists) | 50 | 22 | 19 | 99 | 129050.00 |
| Unified Mode (all features enabled) | 50 | 22 | 21 | 27 | 129050.00 |
| Default Mode (unified, all features) | 50 | 22 | 21 | 25 | 129050.00 |

---

*Benchmark Complete*
