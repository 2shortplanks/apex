#!/usr/bin/env ruby
# Generate single HTML file with all wiki pages
# Uses JavaScript to show/hide pages based on sidebar selection

require 'fileutils'

SCRIPT_DIR = File.expand_path(__dir__)
DOCS_DIR = File.join(SCRIPT_DIR, '..')
HTML_DIR = File.join(DOCS_DIR, 'documentation', 'html')
WIKI_DIR = File.join(DOCS_DIR, 'documentation', 'apex.wiki')

# Find Apex binary
def find_apex_binary
  system_apex = `which apex 2>/dev/null`.strip
  return system_apex if system_apex != '' && File.exist?(system_apex)

  # Try build-release (relative to repo root, not script dir)
  build_apex = File.expand_path('../build-release/apex', __dir__)
  return build_apex if File.exist?(build_apex)

  ['../build/apex', '../build-debug/apex'].each do |path|
    full_path = File.expand_path(path, __dir__)
    return full_path if File.exist?(full_path)
  end

  nil
end

APEX_BIN = find_apex_binary

def parse_sidebar
  sidebar_file = File.join(WIKI_DIR, '_Sidebar.md')
  pages = []

  # Always add Home first
  pages << { name: 'Home', title: 'Home', file: 'Home.md' }

  if File.exist?(sidebar_file)
    sidebar_content = File.read(sidebar_file)
    sidebar_content.scan(/\[([^\]]+)\]\(([^)]+)\)/) do |text, link|
      page_name = link.gsub(/\.md$/, '')
      next if page_name.downcase == 'home'
      pages << { name: page_name, title: text, file: "#{page_name}.md" }
    end
  end

  pages
end

def parse_footer
  footer_file = File.join(WIKI_DIR, '_Footer.md')
  return '' unless File.exist?(footer_file)

  footer_content = `#{APEX_BIN} "#{footer_file}" 2>/dev/null`
  if $?.success? && !footer_content.empty?
    footer_content.strip
  else
    footer_text = File.read(footer_file).strip
    "<p>#{footer_text.gsub(/\n/, '<br>')}</p>"
  end
end

def generate_css
  <<~CSS
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        margin-left: 220px;
      }
      .sidebar {
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
      }
      .sidebar ul {
        list-style: none;
        padding-left: 0;
        margin: 0;
      }
      .sidebar li {
        margin: 0.25em 0;
      }
      .sidebar a {
        color: #333;
        text-decoration: none;
        display: block;
        padding: 0.5em;
        border-radius: 3px;
        cursor: pointer;
      }
      .sidebar a:hover {
        background: #e0e0e0;
      }
      .sidebar a.active {
        background: #ddd;
        font-weight: bold;
      }
      .content {
        padding: 2rem;
        max-width: 900px;
      }
      .page {
        display: none;
      }
      .page.active {
        display: block;
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
      h1, h2, h3, h4, h5, h6 {
        margin-top: 1.5em;
        margin-bottom: 0.5em;
      }
      h1 {
        font-size: 2em;
        border-bottom: 2px solid #eee;
        padding-bottom: 0.3em;
      }
      h2 {
        font-size: 1.5em;
        border-bottom: 1px solid #eee;
        padding-bottom: 0.3em;
      }
      code {
        background: #f0f0f0;
        padding: 0.2em 0.4em;
        border-radius: 3px;
        font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 0.9em;
        margin: 0 0.1em;
      }
      pre {
        background: #f5f5f5;
        padding: 1rem;
        overflow-x: auto;
        border-radius: 4px;
        margin: 1em 0;
      }
      pre code {
        background: none;
        padding: 0;
        margin: 0;
      }
      blockquote {
        border-left: 4px solid #ddd;
        margin: 0;
        padding-left: 1rem;
        color: #666;
      }
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th, td {
        border: 1px solid #ddd;
        padding: 0.5rem;
      }
      th {
        background: #f5f5f5;
      }
      /* Nested lists in page content */
      ul ul, ol ol, ul ol, ol ul {
        padding-left: 1.5em;
        margin-top: 0.25em;
      }
      @media (max-width: 768px) {
        .sidebar {
          display: none;
        }
        body {
          margin-left: 0;
        }
      }
    </style>
  CSS
end

def generate_javascript
  <<~JS
    <script>
      function showPage(pageId) {
        // Hide all pages
        var pages = document.querySelectorAll('.page');
        pages.forEach(function(page) {
          page.classList.remove('active');
        });

        // Show selected page
        var selectedPage = document.getElementById('page-' + pageId);
        if (selectedPage) {
          selectedPage.classList.add('active');
        }

        // Update active link
        var links = document.querySelectorAll('.sidebar a');
        links.forEach(function(link) {
          link.classList.remove('active');
        });
        var activeLink = document.querySelector('.sidebar a[data-page="' + pageId + '"]');
        if (activeLink) {
          activeLink.classList.add('active');
        }

        // Scroll to top
        window.scrollTo(0, 0);

        // Update URL hash without triggering scroll
        if (history.pushState) {
          history.pushState(null, null, '#' + pageId);
        } else {
          window.location.hash = pageId;
        }
      }

      // Initialize on load
      document.addEventListener('DOMContentLoaded', function() {
        // Set up sidebar links
        var links = document.querySelectorAll('.sidebar a');
        links.forEach(function(link) {
          link.addEventListener('click', function(e) {
            e.preventDefault();
            var pageId = this.getAttribute('data-page');
            if (pageId) {
              showPage(pageId);
            }
          });
        });

        // Check for hash on load
        var hash = window.location.hash.substring(1);
        if (hash) {
          showPage(hash);
        } else {
          // Show first page by default
          var firstLink = document.querySelector('.sidebar a[data-page]');
          if (firstLink) {
            var firstPageId = firstLink.getAttribute('data-page');
            showPage(firstPageId);
          }
        }
      });
    </script>
  JS
end

def extract_headers(html_content)
  headers = []
  html_content.scan(/<h([1-6])[^>]*id=["']([^"']+)["'][^>]*>([\s\S]*?)<\/h[1-6]>/i) do |level, id, text|
    text = text.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip
    headers << { level: level.to_i, id: id, text: text } unless text.empty?
  end
  headers
end

def generate_page_toc(headers)
  return '' if headers.empty?

  toc_html = '<nav class="page-toc"><ul>'
  stack = []

  headers.each_with_index do |header, idx|
    level = header[:level]
    next_header = headers[idx + 1]
    next_level = next_header ? next_header[:level] : 1

    while !stack.empty? && stack.last >= level
      toc_html += '</ul></li>'
      stack.pop
    end

    if next_level > level
      toc_html += "<li><a href=\"##{header[:id]}\">#{header[:text]}</a><ul>"
      stack.push(level)
    else
      toc_html += "<li><a href=\"##{header[:id]}\">#{header[:text]}</a></li>"
    end
  end

  while !stack.empty?
    toc_html += '</ul></li>'
    stack.pop
  end

  toc_html += '</ul></nav>'
  toc_html
end

def fix_links_in_html(html_content, page_map)
  # Fix internal links to use JavaScript navigation
  html_content.gsub(/<a\s+([^>]*\s+)?href=["']([^"']+)["']([^>]*)>/i) do |match|
    attrs_before = $1 || ''
    href = $2
    attrs_after = $3 || ''

    # Skip external links, anchors, or files with extensions
    if href =~ /^(https?:\/\/|mailto:|#|.*\.(html|md|pdf|png|jpg|jpeg|gif|svg|webp))/i
      match
    elsif page_map[href]
      # Convert to JavaScript navigation
      page_id = page_map[href]
      "<a #{attrs_before}href=\"##{page_id}\" onclick=\"showPage('#{page_id}'); return false;\"#{attrs_after}>"
    elsif page_map[href.gsub(/\s+/, '-')]
      page_id = page_map[href.gsub(/\s+/, '-')]
      "<a #{attrs_before}href=\"##{page_id}\" onclick=\"showPage('#{page_id}'); return false;\"#{attrs_after}>"
    else
      match
    end
  end
end

def clone_wiki
  wiki_url = 'https://github.com/ApexMarkdown/apex.wiki.git'
  puts "Cloning wiki from GitHub..."

  if File.exist?(WIKI_DIR)
    puts "Wiki directory already exists, removing..."
    FileUtils.rm_rf(WIKI_DIR)
  end

  success = system("git clone #{wiki_url} \"#{WIKI_DIR}\" 2>&1")
  unless success
    puts "Error: Failed to clone wiki from #{wiki_url}"
    exit 1
  end

  puts "Wiki cloned successfully"
end

def cleanup_wiki
  if File.exist?(WIKI_DIR)
    puts "\nCleaning up wiki clone..."
    FileUtils.rm_rf(WIKI_DIR)
    puts "Wiki clone removed"
  end
end

puts "Generating single HTML file with all wiki pages..."

# Ensure output directory exists
FileUtils.mkdir_p(HTML_DIR)

# Clone wiki
clone_wiki

unless File.exist?(WIKI_DIR)
  puts "Error: Wiki directory not found at #{WIKI_DIR}"
  exit 1
end

unless File.exist?(APEX_BIN)
  puts "Error: Apex binary not found at #{APEX_BIN}"
  puts "Please build Apex first or ensure it's in PATH"
  cleanup_wiki
  exit 1
end

# Parse sidebar to get page order
pages = parse_sidebar
puts "Found #{pages.length} pages to process..."

# Parse footer
footer_html = parse_footer

# Process each page
page_map = {}
page_htmls = []

pages.each do |page_info|
  md_file = File.join(WIKI_DIR, page_info[:file])
  next unless File.exist?(md_file)

  puts "Processing #{page_info[:name]}..."

  # Convert to HTML
  html_content = `#{APEX_BIN} "#{md_file}" --standalone --pretty 2>/dev/null`

  if $?.success? && !html_content.empty?
    # Extract body content (remove html/head/body tags)
    body_match = html_content.match(/<body[^>]*>([\s\S]*)<\/body>/i)
    if body_match
      body_content = body_match[1]

      # Extract title
      title_match = body_content.match(/<h1[^>]*>(.*?)<\/h1>/i)
      title = title_match ? title_match[1].gsub(/<[^>]+>/, '').strip : page_info[:title]

      # Extract headers for TOC
      headers = extract_headers(body_content)
      page_toc = generate_page_toc(headers)

      # Fix links
      page_map[page_info[:name]] = page_info[:name].downcase.gsub(/\s+/, '-')
      body_content = fix_links_in_html(body_content, page_map)

      # Inject page TOC after h1
      if body_content =~ /<h1[^>]*>[\s\S]*?<\/h1>/i
        body_content = body_content.sub(/(<h1[^>]*>[\s\S]*?<\/h1>)/i, "\\1\n#{page_toc}")
      end

      # Add footer
      body_content += "\n#{footer_html}" if footer_html.length > 0

      page_htmls << {
        id: page_info[:name].downcase.gsub(/\s+/, '-'),
        title: title,
        content: body_content
      }
    end
  end
end

# Generate sidebar HTML
sidebar_html = '<nav class="sidebar"><ul>'
pages.each do |page_info|
  page_id = page_info[:name].downcase.gsub(/\s+/, '-')
  sidebar_html += "<li><a href=\"##{page_id}\" data-page=\"#{page_id}\">#{page_info[:title]}</a></li>"
end
sidebar_html += '</ul></nav>'

# Generate page containers
pages_html = '<div class="content">'
page_htmls.each do |page|
  pages_html += "<div id=\"page-#{page[:id]}\" class=\"page\">#{page[:content]}</div>"
end
pages_html += '</div>'

# Combine everything
html_output = <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Apex Documentation</title>
  #{generate_css}
</head>
<body>
  #{sidebar_html}
  #{pages_html}
  #{generate_javascript}
</body>
</html>
HTML

# Write output
output_file = File.join(HTML_DIR, 'apex-docs.html')
File.write(output_file, html_output)

puts "\nSingle HTML file generated successfully!"
puts "Output: #{output_file}"
puts "File size: #{(File.size(output_file) / 1024.0 / 1024.0).round(2)} MB"

# Clean up wiki clone
cleanup_wiki
