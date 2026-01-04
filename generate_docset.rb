#!/usr/bin/env ruby
# Generate Dash docset for Apex documentation
#
# Usage:
#   ./generate_docset.rb [single|multi]
#
#   single - Generate single-page CLI options docset (ApexCLI.docset)
#   multi  - Generate multi-page docset from wiki files (Apex.docset, default)

require 'fileutils'
require 'yaml'
require 'uri'

# Only require sqlite3 for multi-page docset
def require_sqlite3
  require 'sqlite3'
rescue LoadError
  puts "Error: sqlite3 gem is required for multi-page docset generation"
  puts "Install it with: gem install sqlite3"
  exit 1
end

MODE = ARGV[0] || 'multi'  # Default to multi-page docset
WIKI_DIR = File.expand_path('../apex.wiki', __dir__)
MMD2CHEATSET = File.expand_path('~/Desktop/Code/mmd2cheatset/mmd2cheatset.rb')

# Find Apex binary - prefer system install, fall back to build-release
def find_apex_binary
  # Try system install first
  system_apex = `which apex 2>/dev/null`.strip
  return system_apex if system_apex != '' && File.exist?(system_apex)

  # Try build-release
  build_apex = File.expand_path('build-release/apex', __dir__)
  return build_apex if File.exist?(build_apex)

  # Try other common build directories
  ['build/apex', 'build-debug/apex'].each do |path|
    full_path = File.expand_path(path, __dir__)
    return full_path if File.exist?(full_path)
  end

  nil
end

APEX_BIN = find_apex_binary

def generate_single_page_docset
  puts "Generating single-page docset using mmd2cheatset..."

  # Create a cheatsheet markdown file for command-line options
  cheatsheet_md = <<~MARKDOWN
    title: Apex Command Line Options
    name: ApexCLI
    keyword: apex

    Complete reference for all Apex command-line flags and options.

    | name | command | note |
    |------|---------|------|
    | Help | -h, --help | Display help message and exit |
    | Version | -v, --version | Display version information and exit |
    | Progress | --[no-]progress | Show progress indicator during processing |
    | Combine | --combine | Concatenate Markdown files into a single stream |
    | MMD Merge | --mmd-merge | Merge files from MultiMarkdown index files |
    | Mode | -m, --mode MODE | Set processor mode (commonmark, gfm, mmd, kramdown, unified) |
    | Output | -o, --output FILE | Write output to a file instead of stdout |
    | Standalone | -s, --standalone | Generate complete HTML document |
    | Style | --style FILE, --css FILE | Link to a CSS file in document head |
    | Embed CSS | --embed-css | Embed CSS file contents into style tag |
    | Script | --script VALUE | Inject script tags (mermaid, mathjax, katex, etc.) |
    | Title | --title TITLE | Set the document title |
    | Pretty | --pretty | Pretty-print HTML with indentation |
    | ARIA | --aria | Add ARIA labels and accessibility attributes |
    | Plugins | --plugins, --no-plugins | Enable or disable plugin processing |
    | List Plugins | --list-plugins | List installed and available plugins |
    | Install Plugin | --install-plugin ID-or-URL | Install a plugin by ID or URL |
    | Uninstall Plugin | --uninstall-plugin ID | Uninstall a locally installed plugin |
    | ID Format | --id-format FORMAT | Set header ID generation format (gfm, mmd, kramdown) |
    | No IDs | --no-ids | Disable automatic header ID generation |
    | Header Anchors | --header-anchors | Generate anchor tags instead of id attributes |
    | Relaxed Tables | --relaxed-tables | Enable relaxed table parsing |
    | No Relaxed Tables | --no-relaxed-tables | Disable relaxed table parsing |
    | Captions | --captions POSITION | Control table caption position (above, below) |
    | No Tables | --no-tables | Disable table support entirely |
    | Alpha Lists | --[no-]alpha-lists | Control alphabetic list markers (a., b., c.) |
    | Mixed Lists | --[no-]mixed-lists | Control mixed list marker types |
    | No Footnotes | --no-footnotes | Disable footnote support |
    | No Smart | --no-smart | Disable smart typography |
    | No Math | --no-math | Disable math support |
    | Autolink | --[no-]autolink | Control automatic linking of URLs and email addresses |
    | Obfuscate Emails | --obfuscate-emails | Obfuscate email links by hex-encoding |
    | Includes | --includes, --no-includes | Enable or disable file inclusion features |
    | Embed Images | --embed-images | Embed local images as base64 data URLs |
    | Base Dir | --base-dir DIR | Set base directory for resolving relative paths |
    | Transforms | --[no-]transforms | Control metadata variable transforms |
    | Meta File | --meta-file FILE | Load metadata from external file |
    | Meta | --meta KEY=VALUE | Set metadata from command line |
    | Bibliography | --bibliography FILE | Specify bibliography file (BibTeX, CSL JSON, CSL YAML) |
    | CSL | --csl FILE | Specify Citation Style Language file |
    | No Bibliography | --no-bibliography | Suppress bibliography output |
    | Link Citations | --link-citations | Link citations to bibliography entries |
    | Show Tooltips | --show-tooltips | Enable tooltips on citations when hovering |
    | Indices | --indices | Enable index processing |
    | No Indices | --no-indices | Disable index processing entirely |
    | No Index | --no-index | Suppress index generation while creating markers |
    | Hardbreaks | --hardbreaks | Treat newlines as hard breaks (GFM style) |
    | Sup Sub | --[no-]sup-sub | Control MultiMarkdown-style superscript and subscript |
    | Divs | --[no-]divs | Control Pandoc fenced divs syntax |
    | Spans | --[no-]spans | Control Pandoc-style bracketed spans |
    | Emoji Autocorrect | --[no-]emoji-autocorrect | Control emoji name autocorrect |
    | Unsafe | --[no-]unsafe | Control whether raw HTML is allowed |
    | Wikilinks | --[no-]wikilinks | Control wiki link syntax |
    | Wikilink Space | --wikilink-space MODE | Control how spaces in wiki links are handled |
    | Wikilink Extension | --wikilink-extension EXT | Add file extension to wiki link URLs |
    | Accept | --accept | Accept all Critic Markup changes |
    | Reject | --reject | Reject all Critic Markup changes |
    [Command Line Options]

    ---

    For complete documentation, see the Apex wiki at https://github.com/ApexMarkdown/apex/wiki
  MARKDOWN

  File.write('Apex_Command_Line_Options.md', cheatsheet_md)

  if File.exist?(MMD2CHEATSET)
    system("#{MMD2CHEATSET} Apex_Command_Line_Options.md")
    FileUtils.rm('Apex_Command_Line_Options.md')
    puts "\nSingle-page docset generated successfully!"
    puts "Docset location: ApexCLI.docset"
  else
    puts "Error: mmd2cheatset.rb not found at #{MMD2CHEATSET}"
    puts "Please check the path or install mmd2cheatset"
    exit 1
  end
end

def extract_headers(html_content)
  headers = []
  # Match headers with IDs, handling multi-line formatting
  html_content.scan(/<h([1-6])[^>]*id=["']([^"']+)["'][^>]*>([\s\S]*?)<\/h[1-6]>/i) do |level, id, text|
    # Remove HTML tags and normalize whitespace
    text = text.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
    headers << { level: level.to_i, id: id, text: text } unless text.empty?
  end
  headers
end

def parse_sidebar_toc
  sidebar_file = File.join(WIKI_DIR, '_Sidebar.md')
  toc_html = '<nav class="main-toc">'
  toc_html += '<ul>'

  # Always add Home first
  toc_html += '<li><a href="Home.html">Home</a></li>'

  if File.exist?(sidebar_file)
    sidebar_content = File.read(sidebar_file)
    # Parse markdown links: [Text](PageName) or [Text](Page-Name)
    sidebar_content.scan(/\[([^\]]+)\]\(([^)]+)\)/) do |text, link|
      # Remove .md extension if present, add .html
      page_name = link.gsub(/\.md$/, '')
      # Skip if it's Home (already added)
      next if page_name.downcase == 'home'
      toc_html += "<li><a href=\"#{page_name}.html\">#{text}</a></li>"
    end
  end

  toc_html += '</ul>'
  toc_html += '</nav>'
  toc_html
end

def generate_page_toc(headers)
  return '' if headers.empty?

  toc_html = '<nav class="page-toc">'
  toc_html += '<ul>'
  stack = []  # Track open list items that need closing

  headers.each_with_index do |header, idx|
    level = header[:level]
    next_header = headers[idx + 1]
    next_level = next_header ? next_header[:level] : 1

    # Close lists if we're going up in level
    while !stack.empty? && stack.last >= level
      toc_html += '</ul></li>'
      stack.pop
    end

    # If next item is deeper, this item will have children
    if next_level > level
      toc_html += "<li><a href=\"##{header[:id]}\">#{header[:text]}</a><ul>"
      stack.push(level)
    else
      toc_html += "<li><a href=\"##{header[:id]}\">#{header[:text]}</a></li>"
    end
  end

  # Close all remaining lists
  while !stack.empty?
    toc_html += '</ul></li>'
    stack.pop
  end

  toc_html += '</ul>'
  toc_html += '</nav>'
  toc_html
end

def inject_toc_into_html(html_content, main_toc_html, page_toc_html)
  # Add CSS for the TOC sidebar and page TOC
  toc_css = <<~CSS
    <style>
      .main-toc {
        position: fixed;
        left: 0;
        top: 0;
        width: auto;
        min-width: 150px;
        max-width: 200px;
        height: 100vh;
        overflow-y: auto;
        background: #f5f5f5;
        border-right: 2px solid #ddd;
        padding: 20px;
        font-size: 0.9em;
        z-index: 100;
        margin-right: 1rem;
      }
      .main-toc ul {
        list-style: none;
        padding-left: 0;
        margin: 0;
      }
      .main-toc li {
        margin: 0.25em 0;
      }
      .main-toc a {
        color: #333;
        text-decoration: none;
        display: block;
        padding: 0.5em;
        border-radius: 3px;
      }
      .main-toc a:hover {
        background: #e0e0e0;
      }
      .page-toc {
        background: #f9f9f9;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 1rem;
        margin: 1.5rem 0;
      }
      .page-toc ul {
        list-style: none;
        padding-left: 0;
        margin: 0;
      }
      .page-toc > ul {
        padding-left: 0;
      }
      .page-toc li {
        margin: 0.25em 0;
      }
      .page-toc a {
        color: #0066cc;
        text-decoration: none;
        display: block;
        padding: 0.25em 0.5em;
        border-radius: 3px;
      }
      .page-toc a:hover {
        background: #e0e0e0;
        color: #004499;
      }
      .page-toc ul ul {
        list-style: none;
        padding-left: 1.5em;
        margin-top: 0.25em;
        margin-left: 0;
      }
      .page-toc ul ul ul {
        padding-left: 1.5em;
      }
      .page-toc ul ul a {
        font-size: 0.9em;
        color: #555;
      }
      .page-toc ul ul ul a {
        font-size: 0.85em;
        color: #666;
      }
      .page-footer {
        background: #f5f5f5;
        border-top: 1px solid #ddd;
        padding: 1.5rem;
        margin-top: 3rem;
        color: #666;
        font-size: 0.9em;
      }
      .page-footer p {
        margin: 0.5em 0;
      }
      .page-footer a {
        color: #0066cc;
        text-decoration: none;
      }
      .page-footer a:hover {
        text-decoration: underline;
      }
      body {
        margin-left: 220px;
      }
      @media (max-width: 768px) {
        .main-toc {
          display: none;
        }
        body {
          margin-left: 0;
        }
      }
    </style>
  CSS

  # Inject CSS into head
  if html_content =~ /(<\/head>)/i
    html_content = html_content.sub(/(<\/head>)/i, "#{toc_css}\\1")
  elsif html_content =~ /(<\/style>)/i
    html_content = html_content.sub(/(<\/style>)/i, "\\1\n#{toc_css}")
  end

  # Inject main TOC into body (left sidebar)
  if html_content =~ /(<body[^>]*>)/i
    html_content = html_content.sub(/(<body[^>]*>)/i, "\\1\n#{main_toc_html}")
  else
    puts "Warning: Could not find <body> tag to inject main TOC"
  end

  # Inject page TOC at top of content (after first h1)
  # Handle multi-line h1 tags (from pretty printing)
  if html_content =~ /<h1[^>]*>[\s\S]*?<\/h1>/i
    html_content = html_content.sub(/(<h1[^>]*>[\s\S]*?<\/h1>)/i, "\\1\n#{page_toc_html}")
  else
    puts "Warning: Could not find <h1> tag to inject page TOC"
  end

  html_content
end

def parse_footer
  footer_file = File.join(WIKI_DIR, '_Footer.md')
  return '' unless File.exist?(footer_file)

  # Convert markdown to HTML using Apex
  footer_html_content = `#{APEX_BIN} "#{footer_file}" 2>/dev/null`

  if $?.success? && !footer_html_content.empty?
    footer_html = '<footer class="page-footer">'
    footer_html += footer_html_content.strip
    footer_html += '</footer>'
    footer_html
  else
    # Fallback: simple text conversion
    footer_content = File.read(footer_file)
    footer_html = '<footer class="page-footer">'
    footer_html += '<p>' + footer_content.strip.gsub(/\n/, '<br>') + '</p>'
    footer_html += '</footer>'
    footer_html
  end
end

def inject_footer_into_html(html_content, footer_html)
  return html_content if footer_html.empty?

  # Inject footer before closing body tag
  if html_content =~ /(<\/body>)/i
    html_content = html_content.sub(/(<\/body>)/i, "#{footer_html}\\1")
  end

  html_content
end

def fix_links_in_html(html_content, available_files)
  # Create a mapping of page names to HTML files
  file_map = {}
  available_files.each do |file|
    basename = File.basename(file, '.html')
    file_map[basename] = "#{basename}.html"
    # Also map with different cases/spaces
    file_map[basename.gsub('-', ' ')] = "#{basename}.html"
    file_map[basename.gsub('-', '_')] = "#{basename}.html"
  end

  # Fix relative links that don't have .html extension
  # Match href="PageName" or href="Page-Name" (but not external links, anchors, or already .html)
  html_content.gsub(/<a\s+([^>]*\s+)?href=["']([^"']+)["']([^>]*)>/i) do |match|
    attrs_before = $1 || ''
    href = $2
    attrs_after = $3 || ''

    # Skip if it's already an external link, anchor, or has extension
    if href =~ /^(https?:\/\/|mailto:|#|.*\.(html|md|pdf|png|jpg|jpeg|gif|svg|webp))/i
      match
    elsif file_map[href]
      # Found a matching file, add .html extension
      "<a #{attrs_before}href=\"#{file_map[href]}\"#{attrs_after}>"
    elsif file_map[href.gsub(/\s+/, '-')]
      # Try with spaces converted to dashes
      fixed_href = file_map[href.gsub(/\s+/, '-')]
      "<a #{attrs_before}href=\"#{fixed_href}\"#{attrs_after}>"
    else
      # Try to find a case-insensitive match
      found = available_files.find { |f| File.basename(f, '.html').downcase == href.downcase }
      if found
        "<a #{attrs_before}href=\"#{File.basename(found)}\"#{attrs_after}>"
      else
        match  # Keep original if no match found
      end
    end
  end
end

def generate_multi_page_docset
  require_sqlite3  # Only needed for multi-page mode

  puts "Generating multi-page docset from wiki files..."

  unless File.exist?(WIKI_DIR)
    puts "Error: Wiki directory not found at #{WIKI_DIR}"
    exit 1
  end

  unless File.exist?(APEX_BIN)
    puts "Error: Apex binary not found at #{APEX_BIN}"
    puts "Please build Apex first: cd build-release && make"
    exit 1
  end

  docset_name = 'Apex.docset'
  docset_path = File.join(Dir.pwd, docset_name)
  contents_path = File.join(docset_path, 'Contents')
  resources_path = File.join(contents_path, 'Resources')
  documents_path = File.join(resources_path, 'Documents')

  # Clean up existing docset
  FileUtils.rm_rf(docset_path) if File.exist?(docset_path)

  # Create directory structure
  FileUtils.mkdir_p(documents_path)

  # Get all markdown files from wiki (excluding special files)
  wiki_files = Dir.glob(File.join(WIKI_DIR, '*.md')).reject do |f|
    basename = File.basename(f)
    basename =~ /^(_|\.)/ || basename == 'commit_message.txt'
  end.sort

  # Ensure Home.md is first (it's the index file)
  home_file = wiki_files.find { |f| File.basename(f) == 'Home.md' }
  if home_file
    wiki_files.delete(home_file)
    wiki_files.unshift(home_file)
  end

  puts "Found #{wiki_files.length} wiki files to process..."

  # Process each wiki file - first pass: convert to HTML
  html_files = []
  wiki_files.each do |md_file|
    basename = File.basename(md_file, '.md')
    html_file = File.join(documents_path, "#{basename}.html")
    html_files << html_file

    puts "Processing #{basename}..."

    # Convert markdown to HTML using Apex
    html_content = `#{APEX_BIN} "#{md_file}" --standalone --pretty 2>/dev/null`

    if $?.success? && !html_content.empty?
      # Write HTML file (will fix links in second pass)
      File.write(html_file, html_content)
    else
      puts "  Warning: Failed to process #{basename}"
    end
  end

  # Generate main TOC from sidebar
  puts "\nGenerating main TOC from sidebar..."
  main_toc_html = parse_sidebar_toc
  puts "Main TOC generated (#{main_toc_html.length} chars)"
  if main_toc_html.length < 100
    puts "Warning: TOC seems too short, checking..."
    puts "First 200 chars: #{main_toc_html[0..200]}"
  end

  # Generate footer
  puts "Generating footer..."
  footer_html = parse_footer
  puts "Footer generated (#{footer_html.length} chars)"

  # Second pass: fix links in all HTML files and add TOCs
  puts "Fixing links and adding TOCs..."
  entries = []
  all_guides = []  # Collect all guide entries for TOC

  html_files.each do |html_file|
    next unless File.exist?(html_file)

    basename = File.basename(html_file, '.html')
    html_content = File.read(html_file)

    # Fix links to add .html extensions
    html_content = fix_links_in_html(html_content, html_files.map { |f| File.basename(f) })

    # Extract title from first h1 or use filename
    title_match = html_content.match(/<h1[^>]*>(.*?)<\/h1>/i)
    title = title_match ? title_match[1].gsub(/<[^>]+>/, '').strip : basename

    # Collect guide info for TOC
    all_guides << { basename: basename, title: title, path: "#{basename}.html" }

    # Extract headers for index and TOC
    headers = extract_headers(html_content)

    # Generate TOC for this page
    page_toc_html = generate_page_toc(headers)
    if page_toc_html.empty?
      puts "  No page TOC for #{basename} (no headers found)"
    else
      puts "  Generated page TOC for #{basename} (#{headers.length} headers)"
    end

    # Inject both TOCs and footer into HTML
    html_content = inject_toc_into_html(html_content, main_toc_html, page_toc_html)
    html_content = inject_footer_into_html(html_content, footer_html)

    # Write updated HTML file with TOCs and footer
    File.write(html_file, html_content)

    # Add main entry
    entries << {
      name: title,
      type: 'Guide',
      path: "#{basename}.html"
    }

    # Add header entries
    headers.each do |header|
      entries << {
        name: header[:text],
        type: 'Section',
        path: "#{basename}.html##{header[:id]}"
      }
    end
  end

  # Add table of contents to Home.html for Dash index
  home_html_file = html_files.find { |f| File.basename(f, '.html') == 'Home' }
  if home_html_file && File.exist?(home_html_file)
    puts "Adding table of contents to index page..."
    html_content = File.read(home_html_file)

    # Generate TOC HTML
    toc_html = "<nav class=\"dash-toc\">\n<h2>Documentation</h2>\n<ul>\n"
    all_guides.each do |guide|
      toc_html += "  <li><a href=\"#{guide[:path]}\">#{guide[:title]}</a></li>\n"
    end
    toc_html += "</ul>\n</nav>\n"

    # Insert TOC after the first h1 or at the beginning of body
    if html_content =~ /(<h1[^>]*>.*?<\/h1>)/i
      html_content = html_content.sub(/(<h1[^>]*>.*?<\/h1>)/i, "\\1\n#{toc_html}")
    elsif html_content =~ /(<body[^>]*>)/i
      html_content = html_content.sub(/(<body[^>]*>)/i, "\\1\n#{toc_html}")
    end

    File.write(home_html_file, html_content)
  end

  # Determine index file
  index_file = if entries.any? { |e| e[:path] == 'Home.html' }
    'Home.html'
  elsif entries.first
    entries.first[:path]
  else
    'index.html'
  end

  # Create Info.plist
  info_plist = <<~PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleIdentifier</key>
      <string>apex</string>
      <key>CFBundleName</key>
      <string>Apex</string>
      <key>DocSetPlatformFamily</key>
      <string>apex</string>
      <key>isDashDocset</key>
      <true/>
      <key>dashIndexFilePath</key>
      <string>#{index_file}</string>
      <key>DashDocSetFamily</key>
      <string>dashtoc</string>
      <key>DashDocSetPluginKeyword</key>
      <string>apex</string>
      <key>DashDocSetFallbackURL</key>
      <string>#{index_file}</string>
      <key>DashDocSetDeclaredInStyle</key>
      <string>originalName</string>
    </dict>
    </plist>
  PLIST

  File.write(File.join(contents_path, 'Info.plist'), info_plist)

  # Create SQLite index
  db_path = File.join(resources_path, 'docSet.dsidx')
  db = SQLite3::Database.new(db_path)

  db.execute <<~SQL
    CREATE TABLE searchIndex(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      type TEXT,
      path TEXT
    );
    CREATE UNIQUE INDEX anchor ON searchIndex(name, type, path);
  SQL

  entries.each do |entry|
    db.execute(
      "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES(?, ?, ?)",
      [entry[:name], entry[:type], entry[:path]]
    )
  end

  db.close

  puts "\nMulti-page docset generated successfully!"
  puts "Docset location: #{docset_path}"
  puts "Total entries: #{entries.length}"
end

case MODE
when 'single'
  generate_single_page_docset
when 'multi'
  generate_multi_page_docset
else
  puts "Unknown mode: #{MODE}"
  puts "Usage: #{$0} [single|multi]"
  exit 1
end
