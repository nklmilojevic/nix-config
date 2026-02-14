#!/bin/bash

# <xbar.title>GitHub Pull Requests</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Your Name</xbar.author>
# <xbar.desc>Shows your created and assigned GitHub PRs</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>

# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# Use SF Symbol for icon
GITHUB_ICON_TITLE=":arrow.triangle.branch:"
GITHUB_ICON_PARAMS_ACTIVE="size=14 sfcolor=white"
GITHUB_ICON_PARAMS_IDLE="size=14 sfcolor=gray"

KEYCHAIN_SERVICE="swiftbar-github"
KEYCHAIN_ACCOUNT="token"

# Try to get token from Keychain
GITHUB_TOKEN=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null)

if [ -z "$GITHUB_TOKEN" ]; then
    echo "! $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
    echo "---"
    echo "GitHub token not configured | color=red"
    echo "---"
    echo "Setup GitHub Token | bash=$0 param1=--setup terminal=true refresh=true"
    echo "---"
    echo "Get token | href=https://github.com/settings/tokens"

    # Handle setup mode
    if [ "$1" = "--setup" ]; then
        echo ""
        echo "Enter your GitHub Personal Access Token"
        echo "(from https://github.com/settings/tokens - needs 'repo' scope):"
        read -r token
        if [ -n "$token" ]; then
            security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w "$token" -U
            echo "Token stored in Keychain!"
            echo "Press any key to close..."
            read -n 1
        fi
    fi
    exit 0
fi

# Handle reset
if [ "$1" = "--reset" ]; then
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null
    echo "Token removed. Refresh to set up again."
    read -n 1
    exit 0
fi

# Get current username
USERNAME=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/user" 2>/dev/null | jq -r '.login')

if [ -z "$USERNAME" ] || [ "$USERNAME" = "null" ]; then
    echo "! $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
    echo "---"
    echo "Failed to get user info | color=red"
    echo "---"
    echo "Reset Token | bash=$0 param1=--reset terminal=true refresh=true"
    exit 0
fi

# Fetch PRs created by user
CREATED_PRS=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/search/issues?q=is:pr+is:open+author:$USERNAME&per_page=15" 2>/dev/null)

# Fetch PRs assigned to user
ASSIGNED_PRS=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/search/issues?q=is:pr+is:open+assignee:$USERNAME&per_page=15" 2>/dev/null)

# Fetch PRs where review is requested
REVIEW_PRS=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/search/issues?q=is:pr+is:open+review-requested:$USERNAME&per_page=15" 2>/dev/null)

# Count PRs
CREATED_COUNT=$(echo "$CREATED_PRS" | jq '.total_count // 0' 2>/dev/null)
ASSIGNED_COUNT=$(echo "$ASSIGNED_PRS" | jq '.total_count // 0' 2>/dev/null)
REVIEW_COUNT=$(echo "$REVIEW_PRS" | jq '.total_count // 0' 2>/dev/null)
TOTAL_COUNT=$((CREATED_COUNT + ASSIGNED_COUNT + REVIEW_COUNT))

# Native notifications for new review requests
CACHE_DIR="${SWIFTBAR_PLUGIN_CACHE_PATH:-$HOME/.cache/swiftbar}"
mkdir -p "$CACHE_DIR"
SEEN_FILE="$CACHE_DIR/github-prs-seen-ids"
touch "$SEEN_FILE"

# Check for new review requests (most important to notify about)
REVIEW_IDS=$(echo "$REVIEW_PRS" | jq -r '.items[].id' 2>/dev/null)

for id in $REVIEW_IDS; do
    if ! grep -q "^review-$id$" "$SEEN_FILE" 2>/dev/null; then
        # Get PR details
        PR=$(echo "$REVIEW_PRS" | jq -r ".items[] | select(.id == $id)" 2>/dev/null)
        TITLE=$(echo "$PR" | jq -r '.title // "New PR"')
        URL=$(echo "$PR" | jq -r '.html_url')
        REPO=$(echo "$PR" | jq -r '.repository_url' | sed 's|https://api.github.com/repos/||')
        USER=$(echo "$PR" | jq -r '.user.login // "Someone"')

        # Send native notification
        NOTIF_TITLE="Review requested by $USER"
        SAFE_TITLE=$(echo "$NOTIF_TITLE" | sed 's/&/and/g')
        SAFE_BODY=$(echo "$TITLE" | sed 's/&/and/g')
        open -g "swiftbar://notify?plugin=github-prs&title=$SAFE_TITLE&body=$SAFE_BODY&href=$URL" 2>/dev/null

        # Mark as seen
        echo "review-$id" >> "$SEEN_FILE"
    fi
done

# Check for new assigned PRs
ASSIGNED_IDS=$(echo "$ASSIGNED_PRS" | jq -r '.items[].id' 2>/dev/null)

for id in $ASSIGNED_IDS; do
    if ! grep -q "^assigned-$id$" "$SEEN_FILE" 2>/dev/null; then
        # Get PR details
        PR=$(echo "$ASSIGNED_PRS" | jq -r ".items[] | select(.id == $id)" 2>/dev/null)
        TITLE=$(echo "$PR" | jq -r '.title // "New PR"')
        URL=$(echo "$PR" | jq -r '.html_url')
        USER=$(echo "$PR" | jq -r '.user.login // "Someone"')

        # Send native notification
        NOTIF_TITLE="Assigned to PR by $USER"
        SAFE_TITLE=$(echo "$NOTIF_TITLE" | sed 's/&/and/g')
        SAFE_BODY=$(echo "$TITLE" | sed 's/&/and/g')
        open -g "swiftbar://notify?plugin=github-prs&title=$SAFE_TITLE&body=$SAFE_BODY&href=$URL" 2>/dev/null

        # Mark as seen
        echo "assigned-$id" >> "$SEEN_FILE"
    fi
done

# Keep only recent IDs in cache (last 200)
tail -200 "$SEEN_FILE" > "$SEEN_FILE.tmp" && mv "$SEEN_FILE.tmp" "$SEEN_FILE"

# Menu bar header
if [ "$TOTAL_COUNT" -gt 0 ]; then
    echo "$TOTAL_COUNT $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_ACTIVE"
else
    echo "$GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
fi

echo "---"
echo "Pull Requests | href=https://github.com/pulls"
echo "---"

# Function to display PRs
display_prs() {
    local prs="$1"
    local items=$(echo "$prs" | jq -r '.items // []')

    echo "$items" | jq -c '.[]' 2>/dev/null | while read -r pr; do
        TITLE=$(echo "$pr" | jq -r '.title')
        URL=$(echo "$pr" | jq -r '.html_url')
        REPO=$(echo "$pr" | jq -r '.repository_url' | sed 's|https://api.github.com/repos/||')
        STATE=$(echo "$pr" | jq -r '.state')
        DRAFT=$(echo "$pr" | jq -r '.draft // false')
        NUMBER=$(echo "$pr" | jq -r '.number')

        # Truncate title
        SHORT_TITLE=$(echo "$TITLE" | cut -c1-45)
        if [ ${#TITLE} -gt 45 ]; then
            SHORT_TITLE="$SHORT_TITLE..."
        fi

        # Style for draft
        if [ "$DRAFT" = "true" ]; then
            STYLE="color=gray"
            PREFIX="[Draft] "
        else
            STYLE="color=black"
            PREFIX=""
        fi

        echo "$PREFIX$SHORT_TITLE | href=$URL $STYLE"
        echo "--$REPO #$NUMBER | href=$URL size=12 color=gray"
    done
}

# Created PRs section
if [ "$CREATED_COUNT" -gt 0 ]; then
    echo "Created by you ($CREATED_COUNT) | color=blue"
    display_prs "$CREATED_PRS"
    echo "---"
fi

# Review requested section
if [ "$REVIEW_COUNT" -gt 0 ]; then
    echo "Review requested ($REVIEW_COUNT) | color=orange"
    display_prs "$REVIEW_PRS"
    echo "---"
fi

# Assigned PRs section
if [ "$ASSIGNED_COUNT" -gt 0 ]; then
    echo "Assigned to you ($ASSIGNED_COUNT) | color=purple"
    display_prs "$ASSIGNED_PRS"
    echo "---"
fi

if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "No open pull requests"
    echo "---"
fi

echo "Refresh | refresh=true"
echo "Open GitHub PRs | href=https://github.com/pulls"
echo "---"
echo "Reset Token | bash=$0 param1=--reset terminal=true refresh=true"
