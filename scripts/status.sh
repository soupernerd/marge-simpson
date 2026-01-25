#!/usr/bin/env bash
set -euo pipefail

# status.sh -- Marge Simpson Status Dashboard
#
# Displays a formatted summary of:
# - Task counts by status (backlog, in-progress, done)
# - Priority breakdown (P0, P1, P2)
# - Last verification result
# - Knowledge entry counts
# - Next task recommendation
#
# Usage:
#   ./scripts/status.sh

# Dynamic folder detection
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MS_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ==============================================================================
# VISUAL HELPERS
# ==============================================================================

write_banner() {
    echo ""
    echo -e "${CYAN}    +=========================================================================+${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    |    __  __    _    ____   ____ _____                                     |${NC}"
    echo -e "${CYAN}    |   |  \\/  |  / \\  |  _ \\ / ___| ____|                                    |${NC}"
    echo -e "${CYAN}    |   | |\\/| | / _ \\ | |_) | |  _|  _|                                      |${NC}"
    echo -e "${CYAN}    |   | |  | |/ ___ \\|  _ <| |_| | |___                                     |${NC}"
    echo -e "${CYAN}    |   |_|  |_/_/   \\_\\_| \\_\\\\____|_____|                                    |${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    |                   S T A T U S   D A S H B O A R D                       |${NC}"
    echo -e "${CYAN}    |                                                                         |${NC}"
    echo -e "${CYAN}    +=========================================================================+${NC}"
    echo ""
}

write_section() {
    local title="$1"
    echo ""
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
    printf "${GRAY}  | ${WHITE}%-73s${GRAY} |${NC}\n" "$title"
    echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
}

write_row() {
    local label="$1"
    local value="$2"
    local color="${3:-$GRAY}"
    printf "    ${GRAY}%-20s${NC}${color}%-50s${NC}\n" "$label" "$value"
}

# ==============================================================================
# PARSING FUNCTIONS
# ==============================================================================

get_tasklist_stats() {
    local tasklist_path="$MS_DIR/tracking/tasklist.md"
    
    # Initialize stats
    BACKLOG=0
    IN_PROGRESS=0
    DONE=0
    P0=0
    P1=0
    P2=0
    NEXT_TASK=""
    NEXT_ID="MS-0001"
    
    if [[ ! -f "$tasklist_path" ]]; then
        return
    fi
    
    local content
    content=$(cat "$tasklist_path")
    
    # Extract Next ID
    if [[ "$content" =~ Next\ ID:\ (MS-[0-9]+) ]]; then
        NEXT_ID="${BASH_REMATCH[1]}"
    fi
    
    # Parse sections
    local current_section=""
    
    while IFS= read -r line; do
        # Detect section headers
        if [[ "$line" =~ ^##[[:space:]]*Backlog ]]; then
            current_section="Backlog"
        elif [[ "$line" =~ ^##[[:space:]]*In-Progress ]]; then
            current_section="InProgress"
        elif [[ "$line" =~ ^##[[:space:]]*Done ]]; then
            current_section="Done"
        fi
        
        # Count MS-#### entries
        if [[ "$line" =~ ^\#\#\#?[[:space:]]*\[?(MS-[0-9]+)\]?[[:space:]]*(.*) ]]; then
            local task_id="${BASH_REMATCH[1]}"
            local task_title="${BASH_REMATCH[2]}"
            
            case "$current_section" in
                Backlog)
                    ((BACKLOG++))
                    if [[ -z "$NEXT_TASK" ]]; then
                        NEXT_TASK="$task_id $task_title"
                    fi
                    ;;
                InProgress)
                    ((IN_PROGRESS++))
                    NEXT_TASK="$task_id $task_title"
                    ;;
                Done)
                    ((DONE++))
                    ;;
            esac
        fi
        
        # Count priorities (only for non-done items)
        if [[ "$current_section" == "Backlog" || "$current_section" == "InProgress" ]]; then
            if [[ "$line" =~ P0 ]]; then
                ((P0++))
            elif [[ "$line" =~ P1 ]]; then
                ((P1++))
            elif [[ "$line" =~ P2 ]]; then
                ((P2++))
            fi
        fi
    done <<< "$content"
}

get_knowledge_stats() {
    local knowledge_path="$MS_DIR/knowledge"
    
    K_DECISIONS=0
    K_PREFERENCES=0
    K_PATTERNS=0
    K_INSIGHTS=0
    K_ARCHIVED=0
    
    if [[ ! -d "$knowledge_path" ]]; then
        return
    fi
    
    # Count entries by pattern [X-###]
    for file in decisions.md preferences.md patterns.md insights.md archive.md; do
        local file_path="$knowledge_path/$file"
        if [[ -f "$file_path" ]]; then
            local count
            count=$(grep -cE "^###[[:space:]]*\[[A-Z]+-[0-9]+\]" "$file_path" 2>/dev/null || echo 0)
            
            case "$file" in
                decisions.md) K_DECISIONS=$count ;;
                preferences.md) K_PREFERENCES=$count ;;
                patterns.md) K_PATTERNS=$count ;;
                insights.md) K_INSIGHTS=$count ;;
                archive.md) K_ARCHIVED=$count ;;
            esac
        fi
    done
}

# ==============================================================================
# MAIN
# ==============================================================================

write_banner

# Gather stats
get_tasklist_stats
get_knowledge_stats

# Task Summary
write_section "TASK SUMMARY"

TOTAL_PENDING=$((BACKLOG + IN_PROGRESS))
TOTAL_ALL=$((TOTAL_PENDING + DONE))

if [[ $BACKLOG -gt 0 ]]; then
    write_row "Backlog" "$BACKLOG items" "$YELLOW"
else
    write_row "Backlog" "$BACKLOG items" "$GREEN"
fi

if [[ $IN_PROGRESS -gt 0 ]]; then
    write_row "In-Progress" "$IN_PROGRESS items" "$CYAN"
else
    write_row "In-Progress" "$IN_PROGRESS items" "$GRAY"
fi

write_row "Done" "$DONE items" "$GREEN"

echo ""

if [[ $P0 -gt 0 ]]; then
    write_row "By Priority" "P0: $P0  |  P1: $P1  |  P2: $P2" "$RED"
elif [[ $P1 -gt 0 ]]; then
    write_row "By Priority" "P0: $P0  |  P1: $P1  |  P2: $P2" "$YELLOW"
else
    write_row "By Priority" "P0: $P0  |  P1: $P1  |  P2: $P2" "$GRAY"
fi

# Progress bar
if [[ $TOTAL_ALL -gt 0 ]]; then
    PCT=$((DONE * 100 / TOTAL_ALL))
    BAR_WIDTH=40
    FILLED=$((BAR_WIDTH * DONE / TOTAL_ALL))
    EMPTY=$((BAR_WIDTH - FILLED))
    
    FILLED_BAR=$(printf '#%.0s' $(seq 1 $FILLED 2>/dev/null) || echo "")
    EMPTY_BAR=$(printf -- '-%.0s' $(seq 1 $EMPTY 2>/dev/null) || echo "")
    
    echo ""
    if [[ $PCT -eq 100 ]]; then
        echo -e "    ${GRAY}Progress            ${GREEN}[${FILLED_BAR}${EMPTY_BAR}] ${PCT}%${NC}"
    elif [[ $PCT -ge 50 ]]; then
        echo -e "    ${GRAY}Progress            ${YELLOW}[${FILLED_BAR}${EMPTY_BAR}] ${PCT}%${NC}"
    else
        echo -e "    ${GRAY}Progress            ${GRAY}[${FILLED_BAR}${EMPTY_BAR}] ${PCT}%${NC}"
    fi
fi

# Knowledge Base
write_section "KNOWLEDGE BASE"

if [[ $K_DECISIONS -gt 0 ]]; then
    write_row "Decisions" "$K_DECISIONS entries" "$CYAN"
else
    write_row "Decisions" "$K_DECISIONS entries" "$GRAY"
fi

if [[ $K_PREFERENCES -gt 0 ]]; then
    write_row "Preferences" "$K_PREFERENCES entries" "$CYAN"
else
    write_row "Preferences" "$K_PREFERENCES entries" "$GRAY"
fi

if [[ $K_PATTERNS -gt 0 ]]; then
    write_row "Patterns" "$K_PATTERNS entries" "$CYAN"
else
    write_row "Patterns" "$K_PATTERNS entries" "$GRAY"
fi

if [[ $K_INSIGHTS -gt 0 ]]; then
    write_row "Insights" "$K_INSIGHTS entries" "$CYAN"
else
    write_row "Insights" "$K_INSIGHTS entries" "$GRAY"
fi

if [[ $K_ARCHIVED -gt 0 ]]; then
    write_row "Archived" "$K_ARCHIVED entries" "$GRAY"
fi

# Next Up
write_section "NEXT UP"

if [[ -n "$NEXT_TASK" ]]; then
    # Truncate if too long
    if [[ ${#NEXT_TASK} -gt 60 ]]; then
        NEXT_TASK="${NEXT_TASK:0:57}..."
    fi
    write_row "Task" "$NEXT_TASK" "$WHITE"
else
    write_row "Task" "No pending tasks - run an audit?" "$GREEN"
fi

write_row "Next ID" "$NEXT_ID" "$GRAY"

echo ""
echo -e "${GRAY}  +---------------------------------------------------------------------------+${NC}"
echo ""
