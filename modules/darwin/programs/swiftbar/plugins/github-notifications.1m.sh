#!/bin/bash

# <xbar.title>GitHub</xbar.title>
# <xbar.version>v1.1</xbar.version>
# <xbar.author>Your Name</xbar.author>
# <xbar.desc>Shows GitHub notifications in menu bar</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>

# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# Use SF Symbol for icon
GITHUB_ICON_TITLE=":bell.fill:"
GITHUB_ICON_PARAMS_ACTIVE="size=14 sfcolor=white"
GITHUB_ICON_PARAMS_IDLE="size=14 sfcolor=gray"

KEYCHAIN_SERVICE="swiftbar-github"
KEYCHAIN_ACCOUNT="token"

sanitize_menu_text() {
  # Avoid breaking SwiftBar parsing when API text contains pipes/newlines.
  echo "$1" | tr '\r\n' '  ' | sed 's/|/¦/g'
}

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
    echo "(from https://github.com/settings/tokens - needs 'notifications' scope):"
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

# Handle mark all as read
if [ "$1" = "--mark-all" ]; then
  curl -s -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/notifications" >/dev/null 2>&1
  exit 0
fi

# Handle open + mark as read
if [ "$1" = "--open" ]; then
  THREAD_ID="$2"
  TARGET_URL="$3"
  if [ -n "$THREAD_ID" ]; then
    curl -s -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      "https://api.github.com/notifications/threads/$THREAD_ID" >/dev/null 2>&1
  fi
  if [ -n "$TARGET_URL" ]; then
    open "$TARGET_URL" >/dev/null 2>&1
  fi
  exit 0
fi

# Fetch notifications from GitHub API
RESPONSE=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/notifications?per_page=25" 2>/dev/null)

# Check if the request was successful
if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
  echo "! $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
  echo "---"
  echo "Failed to fetch notifications | color=red"
  exit 0
fi

# Check for errors
if echo "$RESPONSE" | jq -e '.message' >/dev/null 2>&1; then
  ERROR=$(echo "$RESPONSE" | jq -r '.message')
  echo "! $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
  echo "---"
  echo "API Error: $ERROR | color=red"
  echo "---"
  echo "Reset Token | bash=$0 param1=--reset terminal=true refresh=true"
  exit 0
fi

# Count notifications
NOTIFICATION_COUNT=$(echo "$RESPONSE" | jq 'length' 2>/dev/null)
if ! [[ "$NOTIFICATION_COUNT" =~ ^[0-9]+$ ]]; then
  NOTIFICATION_COUNT=0
fi

# Native notifications for new items
CACHE_DIR="${SWIFTBAR_PLUGIN_CACHE_PATH:-$HOME/.cache/swiftbar}"
mkdir -p "$CACHE_DIR"
SEEN_FILE="$CACHE_DIR/github-notif-seen-ids"
touch "$SEEN_FILE"

# Get current notification IDs
CURRENT_IDS=$(echo "$RESPONSE" | jq -r '.[].id' 2>/dev/null)

# Find first new notification ID only; send one native alert to keep runtime short.
NEW_ID=""
if [ -n "$CURRENT_IDS" ]; then
  while IFS= read -r id; do
    [ -z "$id" ] && continue
    if ! grep -Fxq "$id" "$SEEN_FILE" 2>/dev/null; then
      NEW_ID="$id"
      break
    fi
  done <<EOF
$CURRENT_IDS
EOF
fi

if [ -n "$NEW_ID" ]; then
  NOTIF=$(echo "$RESPONSE" | jq -c --arg id "$NEW_ID" '.[] | select(.id == $id)' 2>/dev/null)
  TITLE=$(echo "$NOTIF" | jq -r '.subject.title // "New notification"')
  TYPE=$(echo "$NOTIF" | jq -r '.subject.type')
  REASON=$(echo "$NOTIF" | jq -r '.reason')
  URL=$(echo "$NOTIF" | jq -r '.subject.url')

  # Convert API URL to web URL
  WEB_URL=$(echo "$URL" | sed 's|api.github.com/repos|github.com|' | sed 's|/pulls/|/pull/|')

  # Format reason for notification title
  case "$REASON" in
  "assign") NOTIF_TITLE="Assigned to you" ;;
  "author") NOTIF_TITLE="Activity on your $TYPE" ;;
  "comment") NOTIF_TITLE="New comment" ;;
  "mention") NOTIF_TITLE="You were mentioned" ;;
  "review_requested") NOTIF_TITLE="Review requested" ;;
  "state_change") NOTIF_TITLE="State changed" ;;
  "team_mention") NOTIF_TITLE="Team mentioned" ;;
  *) NOTIF_TITLE="GitHub: $TYPE" ;;
  esac

  # Fire and forget so plugin output is not delayed by system notification handling.
  SAFE_TITLE=$(echo "$NOTIF_TITLE" | sed 's/&/and/g')
  SAFE_BODY=$(echo "$TITLE" | sed 's/&/and/g')
  (
    open -g "swiftbar://notify?plugin=github-notifications&title=$SAFE_TITLE&body=$SAFE_BODY&href=$WEB_URL"
  ) >/dev/null 2>&1 &
fi

# Mark all current IDs as seen and keep only recent entries.
{
  cat "$SEEN_FILE"
  echo "$CURRENT_IDS"
} | awk 'NF && !seen[$0]++' | tail -100 >"$SEEN_FILE.tmp" && mv "$SEEN_FILE.tmp" "$SEEN_FILE"

# Menu bar header
if [ "$NOTIFICATION_COUNT" -gt 0 ]; then
  echo "$NOTIFICATION_COUNT $GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_ACTIVE"
else
  echo "$GITHUB_ICON_TITLE | $GITHUB_ICON_PARAMS_IDLE"
fi

echo "---"
echo "GitHub Notifications | href=https://github.com/notifications"
echo "---"

if [ "$NOTIFICATION_COUNT" -eq 0 ]; then
  echo "No notifications"
  echo "---"
  echo "Refresh | refresh=true"
  echo "Open GitHub | href=https://github.com"
  echo "---"
  echo "Reset Token | bash=$0 param1=--reset terminal=true refresh=true"
  exit 0
fi

# Process each notification (single jq pass for performance)
echo "$RESPONSE" | jq -r '.[] | [(.id|tostring), (.subject.title // ""), (.subject.type // ""), (.reason // ""), (.repository.full_name // ""), ((.unread // false)|tostring), (.subject.url // "")] | @tsv' 2>/dev/null | while IFS=$'\t' read -r ID TITLE TYPE REASON REPO UNREAD URL; do

  # Convert API URL to web URL
  WEB_URL=$(echo "$URL" | sed 's|api.github.com/repos|github.com|' | sed 's|/pulls/|/pull/|')

  # If it's an issue or PR, we can link directly
  if [ "$TYPE" = "Issue" ] || [ "$TYPE" = "PullRequest" ]; then
    ITEM_URL="$WEB_URL"
  else
    # For other types, link to the repo
    ITEM_URL="https://github.com/$REPO"
  fi
  ACTION="bash=$0 param1=--open param2=$ID param3=$ITEM_URL terminal=false refresh=true"

  # Format reason
  case "$REASON" in
  "assign") REASON_TEXT="assigned" ;;
  "author") REASON_TEXT="author" ;;
  "comment") REASON_TEXT="commented" ;;
  "mention") REASON_TEXT="mentioned" ;;
  "review_requested") REASON_TEXT="review requested" ;;
  "state_change") REASON_TEXT="state changed" ;;
  "subscribed") REASON_TEXT="subscribed" ;;
  "team_mention") REASON_TEXT="team mentioned" ;;
  *) REASON_TEXT="$REASON" ;;
  esac

  # Format type
  case "$TYPE" in
  "PullRequest") TYPE_ICON=":arrow.triangle.pull:" ;;
  "Issue") TYPE_ICON=":circle.dotted:" ;;
  "Release") TYPE_ICON=":tag:" ;;
  "Discussion") TYPE_ICON=":bubble.left.and.bubble.right:" ;;
  *) TYPE_ICON="" ;;
  esac

  # Truncate title if too long
  SHORT_TITLE=$(echo "$TITLE" | cut -c1-50)
  if [ ${#TITLE} -gt 50 ]; then
    SHORT_TITLE="$SHORT_TITLE..."
  fi

  DISPLAY_TITLE=$(sanitize_menu_text "$SHORT_TITLE")
  DISPLAY_REPO=$(sanitize_menu_text "$REPO")

  # Set style for unread
  if [ "$UNREAD" = "true" ]; then
    COLOR="color=black"
    FONT="font=SF Pro Text Bold"
  else
    COLOR="color=gray"
    FONT=""
  fi

  # Output menu item
  echo "$TYPE_ICON $DISPLAY_TITLE | $ACTION $COLOR $FONT"
  echo "--$DISPLAY_REPO ($REASON_TEXT) | $ACTION size=12 color=gray"
done

echo "---"
echo "Refresh | refresh=true"
echo "Mark all as read | bash=$0 param1=--mark-all terminal=false refresh=true"
echo "Open GitHub | href=https://github.com"
echo "---"
echo "Reset Token | bash=$0 param1=--reset terminal=true refresh=true"
