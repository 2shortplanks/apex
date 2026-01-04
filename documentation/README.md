# Apex Documentation Generators

This directory contains scripts to generate documentation from the Apex wiki.

## Scripts

### `generate_docset.rb`

Generates Dash docsets for Apex documentation.

**Usage:**
```bash
./generate_docset.rb [single|multi]
```

- `single` - Generate single-page CLI options docset (ApexCLI.docset)
- `multi` - Generate multi-page docset from wiki files (Apex.docset, default)

**Output:**
- Docsets are generated in `docsets/` directory
- The script automatically clones the wiki from GitHub and cleans up after running

### `generate_single_html.rb`

Generates a single HTML file with all wiki pages, using JavaScript to show/hide pages.

**Usage:**
```bash
./generate_single_html.rb
```

**Output:**
- HTML file is generated in `html/apex-docs.html`
- The script automatically clones the wiki from GitHub and cleans up after running

## Requirements

- Ruby
- Apex binary (in PATH or in `../build-release/apex`)
- `sqlite3` gem (for multi-page docset): `gem install sqlite3`
- `mmd2cheatset` (for single-page docset): Should be at `~/Desktop/Code/mmd2cheatset/mmd2cheatset.rb`
- Git (for cloning the wiki)

## Directory Structure

```
documentation/
├── generate_docset.rb      # Dash docset generator
├── generate_single_html.rb  # Single HTML file generator
├── docsets/                # Generated docsets (gitignored)
│   ├── Apex.docset
│   └── ApexCLI.docset
└── html/                   # Generated HTML files (gitignored)
    └── apex-docs.html
```

## How It Works

Both scripts:
1. Clone the wiki from `https://github.com/ApexMarkdown/apex.wiki.git` into `apex.wiki/`
2. Process the wiki files
3. Generate the output
4. Clean up by removing the cloned wiki directory

This ensures the latest version of the wiki is always used and no local wiki clone is required.
