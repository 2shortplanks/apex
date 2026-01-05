# Markdown Processor Comparison Benchmark

## Available Tools

Found 7 tools:
- apex
- cmark-gfm
- cmark
- pandoc
- multimarkdown
- kramdown
- marked

## Processor Comparison

**File:** `/Users/ttscoff/Desktop/Code/apex/tests/fixtures/comprehensive_test.md` (17008 bytes, 619 lines)

| Processor | Time (ms) | Relative |
|-----------|-----------|----------|
| apex | 12.91 | 1.00x |
| cmark-gfm | 2.90 | .22x |
| cmark | 0.56 | .04x |
| pandoc | 90.62 | 7.01x |
| multimarkdown | 2.25 | .17x |
| kramdown | 331.24 | 25.65x |
| marked | 89.35 | 6.92x |

## Apex Mode Comparison

**Test File:** `/Users/ttscoff/Desktop/Code/apex/tests/fixtures/comprehensive_test.md`

| Mode | Time (ms) | Relative |
|------|-----------|----------|
| commonmark | 2.25 | 1.00x |
| gfm | 12.44 | 5.52x |
| mmd | 13.37 | 5.93x |
| kramdown | 11.72 | 5.20x |
| unified | 13.73 | 6.09x |
| default (unified) | 11.18 | 4.96x |

## Apex Feature Overhead

| Features | Time (ms) |
|----------|-----------|
| CommonMark (minimal) | 2.92 |
| + GFM tables/strikethrough | 12.49 |
| + All Apex features | 13.92 |
| + Pretty printing | 13.34 |
| + Standalone document | 14.30 |

---

*Benchmark Complete*
