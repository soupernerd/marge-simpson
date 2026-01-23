#!/usr/bin/env bash
set -euo pipefail

# cleanup.sh — Marge Simpson Artifact Cleanup
#
# Reports on Marge tracking files and suggests archiving when they get large.
# This script auto-detects its own folder name, so you can rename the folder if needed.
#
# CLEANUP RULES:
# 1. assessment.md  - Suggest archiving if large (no auto-modification)
# 2. tasklist.md    - Suggest archiving if large (no auto-modification)
#
# Usage:
#   ./.marge/scripts/cleanup.sh                    # Analyze and report

# Dynamic folder detection (scripts are now in scripts/ subfolder)
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARGE_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
MS_FOLDER_NAME="$(basename "$MARGE_DIR")"
REPO_ROOT="$(cd "$MARGE_DIR/.." && pwd)"

# Defaults
ARCHIVE_AFTER_DAYS=7

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive-after-days) ARCHIVE_AFTER_DAYS="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo ""
echo "============================================================"
echo "[$MS_FOLDER_NAME] Artifact Cleanup Analysis"
echo "============================================================"
echo ""
echo "  *** PREVIEW MODE - Analysis Only ***"
echo "  This script analyzes Marge files and suggests actions"
echo "  No files are modified automatically"
echo ""
echo "  repo_root: $REPO_ROOT"
echo "  archive_after: $ARCHIVE_AFTER_DAYS days"
echo ""

# ============================================================
# 1. Report on assessment.md
# ============================================================

echo "[1/2] Analyzing assessment.md..."

ASSESSMENT_FILE="$MARGE_DIR/assessment.md"

if [[ -f "$ASSESSMENT_FILE" ]]; then
  ASSESSMENT_SIZE=$(stat -c %s "$ASSESSMENT_FILE" 2>/dev/null || stat -f %z "$ASSESSMENT_FILE" 2>/dev/null)
  ASSESSMENT_KB=$((ASSESSMENT_SIZE / 1024))
  
  echo "  Size: ${ASSESSMENT_KB}KB"
  
  if [[ $ASSESSMENT_KB -gt 50 ]]; then
    echo "  [suggestion] File is large. Consider archiving completed (DONE) entries."
    echo "               You can move old MS-#### entries to assessment_archive.md"
  else
    echo "  Size is reasonable, no action needed"
  fi
else
  echo "  No assessment.md found"
fi

echo ""

# ============================================================
# 2. Report on tasklist.md
# ============================================================

echo "[2/2] Analyzing tasklist.md..."

TASKLIST_FILE="$MARGE_DIR/tasklist.md"

if [[ -f "$TASKLIST_FILE" ]]; then
  TASKLIST_SIZE=$(stat -c %s "$TASKLIST_FILE" 2>/dev/null || stat -f %z "$TASKLIST_FILE" 2>/dev/null)
  TASKLIST_KB=$((TASKLIST_SIZE / 1024))
  TASKLIST_LINES=$(wc -l < "$TASKLIST_FILE" 2>/dev/null || echo 0)
  
  echo "  Size: ${TASKLIST_KB}KB, $TASKLIST_LINES lines"
  
  if [[ $TASKLIST_KB -gt 20 ]]; then
    echo "  [suggestion] Consider moving old DONE items to a 'Completed Archive' section"
  else
    echo "  Size is reasonable, no action needed"
  fi
else
  echo "  No tasklist.md found"
fi

echo ""

# ============================================================
# Summary
# ============================================================

echo "============================================================"
echo "[OK] Analysis complete"
echo "============================================================"
echo ""
