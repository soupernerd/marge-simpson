#!/usr/bin/env bash
set -euo pipefail

# decay.sh — Marge Simpson Knowledge Decay Scanner
#
# Scans knowledge/*.md files for entries with old Last Accessed dates.
# Flags entries for review or auto-archives based on decay rules:
#
# - Last Accessed > 90 days → Flag for review
# - Insight unverified > 60 days → Mark for verification
# - Weak preference + > 90 days → Auto-archive (with --auto-archive)
# - Pattern not observed recently → Flag for review
#
# Usage:
#   ./marge_simpson/scripts/decay.sh
#   ./marge_simpson/scripts/decay.sh --auto-archive
#   ./marge_simpson/scripts/decay.sh --days-threshold 60 --preview

# Dynamic folder detection
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
KNOWLEDGE_PATH="$MS_DIR/knowledge"

# Defaults
AUTO_ARCHIVE=false
DAYS_THRESHOLD=90
PREVIEW=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto-archive) AUTO_ARCHIVE=true; shift ;;
    --days-threshold) DAYS_THRESHOLD="$2"; shift 2 ;;
    --preview) PREVIEW=true; shift ;;
    *) shift ;;
  esac
done

TODAY=$(date +%s)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

write_banner() {
    echo ""
    echo -e "${YELLOW}    +=========================================================================+${NC}"
    echo -e "${YELLOW}    |                                                                         |${NC}"
    echo -e "${YELLOW}    |    __  __    _    ____   ____ _____                                     |${NC}"
    echo -e "${YELLOW}    |   |  \\/  |  / \\  |  _ \\ / ___| ____|                                    |${NC}"
    echo -e "${YELLOW}    |   | |\\/| | / _ \\ | |_) | |  _|  _|                                      |${NC}"
    echo -e "${YELLOW}    |   | |  | |/ ___ \\|  _ <| |_| | |___                                     |${NC}"
    echo -e "${YELLOW}    |   |_|  |_/_/   \\_\\_| \\_\\\\____|_____|                                    |${NC}"
    echo -e "${YELLOW}    |                                                                         |${NC}"
    echo -e "${YELLOW}    |              K N O W L E D G E   D E C A Y   S C A N                    |${NC}"
    echo -e "${YELLOW}    |                                                                         |${NC}"
    echo -e "${YELLOW}    +=========================================================================+${NC}"
    echo ""
}

write_section() {
    local title="$1"
    echo ""
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
    printf "${GRAY}  | ${WHITE}%-73s${GRAY} |${NC}\n" "$title"
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
}

write_entry() {
    local id="$1"
    local title="$2"
    local issue="$3"
    local color="${4:-$YELLOW}"
    
    # Truncate title if too long
    if [[ ${#title} -gt 35 ]]; then
        title="${title:0:32}..."
    fi
    
    echo -e "    ${color}[${id}]${NC} ${WHITE}${title}${NC} ${GRAY}- ${issue}${NC}"
}

# ==============================================================================
# PARSING FUNCTIONS
# ==============================================================================

# Parse date string (YYYY-MM-DD) to epoch seconds
# Returns empty string if date is invalid or unparseable
parse_date() {
    local date_str="$1"
    if [[ -z "$date_str" ]]; then
        echo ""
        return
    fi
    
    # Validate format first (YYYY-MM-DD)
    if [[ ! "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo ""
        return
    fi
    
    # Try GNU date first, then BSD date
    local result
    result=$(date -d "$date_str" +%s 2>/dev/null) || \
    result=$(date -j -f "%Y-%m-%d" "$date_str" +%s 2>/dev/null) || \
    result=""
    
    echo "$result"
}

# Calculate days between two epoch timestamps
days_old() {
    local then="$1"
    local now="$2"
    if [[ -n "$then" && -n "$now" ]]; then
        echo $(( (now - then) / 86400 ))
    else
        echo ""
    fi
}

# Scan a knowledge file for entries
scan_file() {
    local file_path="$1"
    local file_name
    file_name=$(basename "$file_path")
    
    if [[ ! -f "$file_path" ]]; then
        return
    fi
    
    local content
    content=$(cat "$file_path")
    
    # Extract entries using grep/sed (looking for ### [X-###] pattern)
    local in_entry=false
    local current_id=""
    local current_title=""
    local last_accessed=""
    local strength=""
    local verified=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]]*\[([A-Z]+-[0-9]+)\][[:space:]]*(.*) ]]; then
            # If we were processing an entry, output it
            if [[ -n "$current_id" ]]; then
                process_entry "$current_id" "$current_title" "$last_accessed" "$strength" "$verified" "$file_name"
            fi
            
            # Start new entry
            current_id="${BASH_REMATCH[1]}"
            current_title="${BASH_REMATCH[2]}"
            last_accessed=""
            strength=""
            verified=""
            in_entry=true
        elif [[ "$in_entry" == "true" ]]; then
            # Look for metadata within entry
            if [[ "$line" =~ Last[[:space:]]Accessed:[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
                last_accessed="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ (Observed|Stated|Date):[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
                if [[ -z "$last_accessed" ]]; then
                    last_accessed="${BASH_REMATCH[2]}"
                fi
            elif [[ "$line" =~ Strength:[[:space:]]*(Weak|Moderate|Strong) ]]; then
                strength="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ Verified:[[:space:]]*\[[[:space:]]\] ]]; then
                verified="false"
            elif [[ "$line" =~ Verified:[[:space:]]*\[x\] ]]; then
                verified="true"
            fi
        fi
    done <<< "$content"
    
    # Process last entry
    if [[ -n "$current_id" ]]; then
        process_entry "$current_id" "$current_title" "$last_accessed" "$strength" "$verified" "$file_name"
    fi
}

# Arrays to collect findings
declare -a STALE_ENTRIES=()
declare -a UNVERIFIED_INSIGHTS=()
declare -a WEAK_OLD_PREFERENCES=()
TOTAL_ENTRIES=0

process_entry() {
    local id="$1"
    local title="$2"
    local last_accessed="$3"
    local strength="$4"
    local verified="$5"
    local file_name="$6"
    
    ((TOTAL_ENTRIES++))
    
    # Skip entries without dates
    if [[ -z "$last_accessed" ]]; then
        return
    fi
    
    local accessed_epoch
    accessed_epoch=$(parse_date "$last_accessed")
    
    if [[ -z "$accessed_epoch" ]]; then
        return
    fi
    
    local days
    days=$(days_old "$accessed_epoch" "$TODAY")
    
    if [[ -z "$days" ]]; then
        return
    fi
    
    # Check for unverified insights > 60 days
    if [[ "$file_name" == "insights.md" && "$verified" == "false" && $days -gt 60 ]]; then
        UNVERIFIED_INSIGHTS+=("$id|$title|Unverified for $days days")
    fi
    
    # Check for weak preferences > threshold
    if [[ "$file_name" == "preferences.md" && "$strength" == "Weak" && $days -gt $DAYS_THRESHOLD ]]; then
        WEAK_OLD_PREFERENCES+=("$id|$title|Weak + $days days old")
    fi
    
    # Check for general staleness
    if [[ $days -gt $DAYS_THRESHOLD ]]; then
        local color="$YELLOW"
        if [[ $days -gt 180 ]]; then
            color="$RED"
        elif [[ $days -gt 120 ]]; then
            color="$YELLOW"
        fi
        STALE_ENTRIES+=("$id|$title|$days days old|$color")
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

write_banner

if [[ ! -d "$KNOWLEDGE_PATH" ]]; then
    echo "  No knowledge/ folder found at: $KNOWLEDGE_PATH"
    echo "  Nothing to scan."
    exit 0
fi

echo -e "  ${GRAY}Scanning: $KNOWLEDGE_PATH${NC}"
echo -e "  ${GRAY}Threshold: $DAYS_THRESHOLD days${NC}"
if [[ "$PREVIEW" == "true" ]]; then
    echo -e "  ${MAGENTA}Mode: PREVIEW (no changes)${NC}"
fi
if [[ "$AUTO_ARCHIVE" == "true" ]]; then
    echo -e "  ${YELLOW}Auto-archive: ENABLED${NC}"
fi

# Scan all knowledge files
for file in decisions.md preferences.md patterns.md insights.md; do
    scan_file "$KNOWLEDGE_PATH/$file"
done

if [[ $TOTAL_ENTRIES -eq 0 ]]; then
    echo ""
    echo -e "  ${GRAY}No knowledge entries found.${NC}"
    echo -e "  ${GREEN}Knowledge base is empty - nothing to decay.${NC}"
    exit 0
fi

# Report findings
HAS_ISSUES=false

if [[ ${#STALE_ENTRIES[@]} -gt 0 ]]; then
    HAS_ISSUES=true
    write_section "STALE ENTRIES (> $DAYS_THRESHOLD days)"
    for entry in "${STALE_ENTRIES[@]}"; do
        IFS='|' read -r id title issue color <<< "$entry"
        write_entry "$id" "$title" "$issue" "$color"
    done
fi

if [[ ${#UNVERIFIED_INSIGHTS[@]} -gt 0 ]]; then
    HAS_ISSUES=true
    write_section "UNVERIFIED INSIGHTS (> 60 days)"
    for entry in "${UNVERIFIED_INSIGHTS[@]}"; do
        IFS='|' read -r id title issue <<< "$entry"
        write_entry "$id" "$title" "$issue" "$CYAN"
    done
fi

if [[ ${#WEAK_OLD_PREFERENCES[@]} -gt 0 ]]; then
    HAS_ISSUES=true
    write_section "WEAK PREFERENCES (candidates for archive)"
    for entry in "${WEAK_OLD_PREFERENCES[@]}"; do
        IFS='|' read -r id title issue <<< "$entry"
        write_entry "$id" "$title" "$issue" "$MAGENTA"
    done
fi

# Summary
write_section "SUMMARY"

STALE_COUNT=${#STALE_ENTRIES[@]}
HEALTHY_COUNT=$((TOTAL_ENTRIES - STALE_COUNT))
if [[ $TOTAL_ENTRIES -gt 0 ]]; then
    HEALTH_PCT=$((HEALTHY_COUNT * 100 / TOTAL_ENTRIES))
else
    HEALTH_PCT=100
fi

echo ""
echo -e "    ${GRAY}Total entries:      ${WHITE}$TOTAL_ENTRIES${NC}"
if [[ $HEALTH_PCT -ge 80 ]]; then
    echo -e "    ${GRAY}Healthy:            ${GREEN}$HEALTHY_COUNT ($HEALTH_PCT%)${NC}"
elif [[ $HEALTH_PCT -ge 50 ]]; then
    echo -e "    ${GRAY}Healthy:            ${YELLOW}$HEALTHY_COUNT ($HEALTH_PCT%)${NC}"
else
    echo -e "    ${GRAY}Healthy:            ${RED}$HEALTHY_COUNT ($HEALTH_PCT%)${NC}"
fi
if [[ $STALE_COUNT -eq 0 ]]; then
    echo -e "    ${GRAY}Stale:              ${GREEN}$STALE_COUNT${NC}"
else
    echo -e "    ${GRAY}Stale:              ${YELLOW}$STALE_COUNT${NC}"
fi
UNVERIFIED_COUNT=${#UNVERIFIED_INSIGHTS[@]}
if [[ $UNVERIFIED_COUNT -eq 0 ]]; then
    echo -e "    ${GRAY}Unverified:         ${GREEN}$UNVERIFIED_COUNT${NC}"
else
    echo -e "    ${GRAY}Unverified:         ${CYAN}$UNVERIFIED_COUNT${NC}"
fi

echo ""

if [[ "$HAS_ISSUES" == "false" ]]; then
    echo -e "  ${GREEN}[OK] Knowledge base is healthy!${NC}"
else
    echo -e "  ${WHITE}Recommendations:${NC}"
    if [[ $STALE_COUNT -gt 0 ]]; then
        echo -e "    ${GRAY}- Review stale entries - update Last Accessed or archive${NC}"
    fi
    if [[ $UNVERIFIED_COUNT -gt 0 ]]; then
        echo -e "    ${GRAY}- Verify or archive unverified insights${NC}"
    fi
    if [[ ${#WEAK_OLD_PREFERENCES[@]} -gt 0 && "$AUTO_ARCHIVE" == "false" ]]; then
        echo -e "    ${GRAY}- Run with --auto-archive to clean up weak preferences${NC}"
    fi
fi

echo ""
echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
echo ""

exit 0
