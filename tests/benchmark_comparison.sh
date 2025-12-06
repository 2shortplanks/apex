#!/bin/bash
# Comparative benchmark: Apex vs other Markdown processors

set -e

ITERATIONS=20
TEST_FILES=(
	"tests/comprehensive_test.md"
)

# Add larger test files if they exist
[ -f "tests/large_doc.md" ] && TEST_FILES+=("tests/large_doc.md")

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Markdown Processor Comparison Benchmark                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check which tools are available
TOOLS=()
command -v ./build/apex >/dev/null && TOOLS+=("apex:./build/apex")
command -v cmark-gfm >/dev/null && TOOLS+=("cmark-gfm:cmark-gfm -e table -e strikethrough -e autolink")
command -v cmark >/dev/null && TOOLS+=("cmark:cmark")
command -v pandoc >/dev/null && TOOLS+=("pandoc:pandoc -f markdown -t html")
command -v multimarkdown >/dev/null && TOOLS+=("multimarkdown:multimarkdown")
command -v kramdown >/dev/null && TOOLS+=("kramdown:kramdown")
command -v marked >/dev/null && TOOLS+=("marked:marked")

echo "Available tools: ${#TOOLS[@]}"
for tool in "${TOOLS[@]}"; do
	echo "  - ${tool%%:*}"
done
echo ""

# Function to benchmark a single tool
benchmark_tool() {
	local name="$1"
	local cmd="$2"
	local file="$3"
	local iterations="$4"

	# Warm-up
	eval "$cmd \"$file\"" >/dev/null 2>&1 || return 1

	# Timed runs using hyperfine if available, else manual timing
	if command -v hyperfine >/dev/null 2>&1; then
		result=$(hyperfine --warmup 3 --runs "$iterations" --export-json /dev/stdout \
			"$cmd \"$file\"" 2>/dev/null | jq -r '.results[0].mean * 1000' 2>/dev/null)
		echo "${result:-N/A}"
	else
		local total=0
		for i in $(seq 1 $iterations); do
			local start=$(python3 -c 'import time; print(int(time.time() * 1000))')
			eval "$cmd \"$file\"" >/dev/null 2>&1
			local end=$(python3 -c 'import time; print(int(time.time() * 1000))')
			total=$((total + end - start))
		done
		echo "$((total / iterations))"
	fi
}

# Run benchmarks for each file
for file in "${TEST_FILES[@]}"; do
	if [ ! -f "$file" ]; then
		echo "⚠️  File not found: $file"
		continue
	fi

	size=$(wc -c <"$file" | tr -d ' ')
	lines=$(wc -l <"$file" | tr -d ' ')

	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo "📄 $file ($size bytes, $lines lines)"
	echo ""
	printf "%-20s %12s %12s\n" "Processor" "Time (ms)" "Relative"
	printf "%-20s %12s %12s\n" "---------" "---------" "--------"

	baseline=""
	for tool in "${TOOLS[@]}"; do
		name="${tool%%:*}"
		cmd="${tool#*:}"

		result=$(benchmark_tool "$name" "$cmd" "$file" "$ITERATIONS" 2>/dev/null)

		if [ -n "$result" ] && [ "$result" != "N/A" ]; then
			if [ -z "$baseline" ]; then
				baseline="$result"
				relative="1.00x"
			else
				relative=$(echo "scale=2; $result / $baseline" | bc 2>/dev/null || echo "N/A")
				relative="${relative}x"
			fi
			printf "%-20s %12.2f %12s\n" "$name" "$result" "$relative"
		else
			printf "%-20s %12s %12s\n" "$name" "failed" "-"
		fi
	done
	echo ""
done

# Apex mode comparison
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Apex Mode Comparison (${TEST_FILES[0]})"
echo ""
printf "%-25s %12s\n" "Mode" "Time (ms)"
printf "%-25s %12s\n" "----" "---------"

for mode in "commonmark" "gfm" "mmd" "kramdown" "unified"; do
	result=$(benchmark_tool "apex-$mode" "./build/apex -m $mode" "${TEST_FILES[0]}" "$ITERATIONS" 2>/dev/null)
	printf "%-25s %12.2f\n" "$mode" "$result"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Apex Feature Overhead"
echo ""
printf "%-30s %12s\n" "Features" "Time (ms)"
printf "%-30s %12s\n" "--------" "---------"

base=$(benchmark_tool "base" "./build/apex -m commonmark --no-ids" "${TEST_FILES[0]}" "$ITERATIONS")
printf "%-30s %12.2f\n" "CommonMark (minimal)" "$base"

with_tables=$(benchmark_tool "tables" "./build/apex -m gfm" "${TEST_FILES[0]}" "$ITERATIONS")
printf "%-30s %12.2f\n" "+ GFM tables/strikethrough" "$with_tables"

with_all=$(benchmark_tool "all" "./build/apex" "${TEST_FILES[0]}" "$ITERATIONS")
printf "%-30s %12.2f\n" "+ All Apex features" "$with_all"

with_pretty=$(benchmark_tool "pretty" "./build/apex --pretty" "${TEST_FILES[0]}" "$ITERATIONS")
printf "%-30s %12.2f\n" "+ Pretty printing" "$with_pretty"

with_standalone=$(benchmark_tool "standalone" "./build/apex --standalone --pretty" "${TEST_FILES[0]}" "$ITERATIONS")
printf "%-30s %12.2f\n" "+ Standalone document" "$with_standalone"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Benchmark Complete                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
