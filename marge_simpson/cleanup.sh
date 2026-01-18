#!/usr/bin/env bash
set -euo pipefail

# cleanup.sh — Marge Simpson Artifact Cleanup
#
# Intelligent cleanup of Marge artifacts. Safe by default: preview mode unless -confirm is passed.
# This script auto-detects its own folder name, so you can rename the folder if needed.
#
# CLEANUP RULES:
# 1. verify_logs/   - Keep last N logs (default 10) OR logs within M days, whichever is more
# 2. assessment.md  - Suggest archiving if large (no auto-modification)
# 3. tasklist.md    - Suggest archiving if large (no auto-modification)
# 4. instructions_log.md - Never modify (standing instructions are permanent)
#
# Usage:
#   ./cleanup.sh                    # Preview mode (safe)
#   ./cleanup.sh --confirm          # Actually perform cleanup
#   ./cleanup.sh --keep-logs 20     # Keep more logs

# Dynamic folder detection — works regardless of folder name
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_FOLDER_NAME="$(basename "$SCRIPT_DIR")"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MARGE_DIR="$SCRIPT_DIR"

# Defaults
KEEP_LOGS=10
ARCHIVE_AFTER_DAYS=7
CONFIRM=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm) CONFIRM=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --keep-logs) KEEP_LOGS="$2"; shift 2 ;;
    --archive-after-days) ARCHIVE_AFTER_DAYS="$2"; shift 2 ;;
    *) shift ;;
  esac
done

PREVIEW_MODE=true
if [[ "$CONFIRM" == "true" ]]; then
  PREVIEW_MODE=false
fi

echo ""
echo "============================================================"
echo "[$MS_FOLDER_NAME] Intelligent Cleanup"
echo "============================================================"
echo ""
echo "  repo_root: $REPO_ROOT"
if [[ "$PREVIEW_MODE" == "true" ]]; then
  echo "  mode: PREVIEW (pass --confirm to apply)"
else
  echo "  mode: APPLYING CHANGES"
fi
echo "  keep_logs: $KEEP_LOGS minimum"
echo "  archive_after: $ARCHIVE_AFTER_DAYS days"
echo ""

CUTOFF_SECONDS=$((ARCHIVE_AFTER_DAYS * 86400))
LOGS_REMOVED=0
LOGS_BYTES_FREED=0

# ============================================================
# 1. Clean verify_logs/ - Keep last N OR within M days
# ============================================================

echo "[1/3] Analyzing verify_logs/..."

LOG_DIR="$MARGE_DIR/verify_logs"

if [[ -d "$LOG_DIR" ]]; then
  # Get all log files sorted by modification time (newest first)
  mapfile -t ALL_LOGS < <(find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2-)
  
  TOTAL_LOGS=${#ALL_LOGS[@]}
  
  if [[ $TOTAL_LOGS -gt $KEEP_LOGS ]]; then
    NOW=$(date +%s)
    
    for ((i=KEEP_LOGS; i<TOTAL_LOGS; i++)); do
      LOG_FILE="${ALL_LOGS[$i]}"
      if [[ -f "$LOG_FILE" ]]; then
        FILE_MTIME=$(stat -c %Y "$LOG_FILE" 2>/dev/null || stat -f %m "$LOG_FILE" 2>/dev/null)
        AGE=$((NOW - FILE_MTIME))
        
        if [[ $AGE -gt $CUTOFF_SECONDS ]]; then
          FILE_SIZE=$(stat -c %s "$LOG_FILE" 2>/dev/null || stat -f %z "$LOG_FILE" 2>/dev/null)
          LOGS_BYTES_FREED=$((LOGS_BYTES_FREED + FILE_SIZE))
          ((LOGS_REMOVED++))
          
          if [[ "$VERBOSE" == "true" ]] || [[ "$PREVIEW_MODE" == "true" ]]; then
            echo "  [remove] $(basename "$LOG_FILE") - $((FILE_SIZE / 1024))KB"
          fi
          
          if [[ "$PREVIEW_MODE" == "false" ]]; then
            rm -f "$LOG_FILE"
          fi
        fi
      fi
    done
    
    echo "  Total: $TOTAL_LOGS logs, keeping $KEEP_LOGS minimum + any recent"
    if [[ "$PREVIEW_MODE" == "true" ]]; then
      echo "  Result: $LOGS_REMOVED logs would be removed"
    else
      echo "  Result: $LOGS_REMOVED logs removed"
    fi
  else
    echo "  Total: $TOTAL_LOGS logs (below $KEEP_LOGS threshold, keeping all)"
  fi
else
  echo "  No verify_logs/ directory found"
fi

echo ""

# ============================================================
# 2. Report on assessment.md (no auto-modification)
# ============================================================

echo "[2/3] Analyzing assessment.md..."

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
# 3. Report on tasklist.md (no auto-modification)
# ============================================================

echo "[3/3] Analyzing tasklist.md..."

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
echo "[summary]"
echo "============================================================"
echo ""
if [[ "$PREVIEW_MODE" == "true" ]]; then
  echo "  Logs: $LOGS_REMOVED would be removed ($((LOGS_BYTES_FREED / 1024))KB)"
else
  echo "  Logs: $LOGS_REMOVED removed ($((LOGS_BYTES_FREED / 1024))KB)"
fi
echo ""

if [[ "$PREVIEW_MODE" == "true" ]]; then
  echo "[!] PREVIEW MODE - no changes made"
  echo "    Run with --confirm to apply these changes"
else
  echo "[OK] Changes applied"
fi
echo ""
