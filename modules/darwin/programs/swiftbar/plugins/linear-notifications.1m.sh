#!/bin/bash

# <xbar.title>Linear Notifications</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Your Name</xbar.author>
# <xbar.desc>Shows Linear notifications in menu bar</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>

# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# Use SF Symbol for icon
LINEAR_ICON_TITLE=":lineweight:"
LINEAR_ICON_PARAMS_ACTIVE="size=14 sfcolor=white"
LINEAR_ICON_PARAMS_IDLE="size=14 sfcolor=gray"

KEYCHAIN_SERVICE="swiftbar-linear"
KEYCHAIN_ACCOUNT="api-key"

# Try to get token from Keychain
LINEAR_API_KEY=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null)

if [ -z "$LINEAR_API_KEY" ]; then
    echo "! $LINEAR_ICON_TITLE | $LINEAR_ICON_PARAMS_IDLE"
    echo "---"
    echo "Linear API key not configured | color=red"
    echo "---"
    echo "Setup Linear API Key | bash=$0 param1=--setup terminal=true refresh=true"
    echo "---"
    echo "Get API key | href=https://linear.app/settings/api"

    # Handle setup mode
    if [ "$1" = "--setup" ]; then
        echo ""
        echo "Enter your Linear API key (from https://linear.app/settings/api):"
        read -r api_key
        if [ -n "$api_key" ]; then
            security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w "$api_key" -U
            echo "API key stored in Keychain!"
            echo "Press any key to close..."
            read -n 1
        fi
    fi
    exit 0
fi

# Handle mark all as read
if [ "$1" = "--mark-all" ]; then
    READ_AT=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    IDS=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: $LINEAR_API_KEY" \
        -d '{"query": "{ notifications(first: 50) { nodes { id readAt } } }"}' \
        "https://api.linear.app/graphql" | jq -r '.data.notifications.nodes[] | select(.readAt == null) | .id')
    for NOTIF_ID in $IDS; do
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: $LINEAR_API_KEY" \
            -d "{\"query\": \"mutation { notificationUpdate(id: \\\"$NOTIF_ID\\\", input: { readAt: \\\"$READ_AT\\\" }) { success } }\"}" \
            "https://api.linear.app/graphql" >/dev/null 2>&1
    done
    exit 0
fi

# Handle open + mark as read
if [ "$1" = "--open" ]; then
    NOTIF_ID="$2"
    ISSUE_URL="$3"
    if [ -n "$NOTIF_ID" ]; then
        READ_AT=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: $LINEAR_API_KEY" \
            -d "{\"query\": \"mutation { notificationUpdate(id: \\\"$NOTIF_ID\\\", input: { readAt: \\\"$READ_AT\\\" }) { success } }\"}" \
            "https://api.linear.app/graphql" >/dev/null 2>&1
    fi
    if [ -n "$ISSUE_URL" ]; then
        open "$ISSUE_URL" >/dev/null 2>&1
    fi
    exit 0
fi

# GraphQL query to fetch notifications (using inline fragments for different notification types)
QUERY='{"query": "{ notifications(first: 20) { nodes { id type readAt createdAt inboxUrl title subtitle actor { name } ... on IssueNotification { issue { id identifier title url team { name } } comment { id body } } ... on ProjectNotification { project { id name url } projectUpdate { id body } } } } }"}'

# Fetch notifications from Linear API
RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: $LINEAR_API_KEY" \
    -d "$QUERY" \
    "https://api.linear.app/graphql" 2>/dev/null)

# Check if the request was successful
if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    echo "! $LINEAR_ICON_TITLE | $LINEAR_ICON_PARAMS_IDLE"
    echo "---"
    echo "Failed to fetch notifications | color=red"
    exit 0
fi

# Check for errors in response
ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // empty' 2>/dev/null)
if [ -n "$ERROR" ]; then
    echo "! $LINEAR_ICON_TITLE | $LINEAR_ICON_PARAMS_IDLE"
    echo "---"
    echo "API Error: $ERROR | color=red"
    echo "---"
    echo "Reset API Key | bash=$0 param1=--reset terminal=true refresh=true"

    if [ "$1" = "--reset" ]; then
        security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null
        echo "API key removed. Refresh to set up again."
        read -n 1
    fi
    exit 0
fi

# Parse notifications
NOTIFICATIONS=$(echo "$RESPONSE" | jq -r '.data.notifications.nodes // []' 2>/dev/null)

# Count unread notifications
UNREAD_COUNT=$(echo "$NOTIFICATIONS" | jq '[.[] | select(.readAt == null)] | length' 2>/dev/null)

# Native notifications for new items
CACHE_DIR="${SWIFTBAR_PLUGIN_CACHE_PATH:-$HOME/.cache/swiftbar}"
mkdir -p "$CACHE_DIR"
SEEN_FILE="$CACHE_DIR/linear-seen-ids"
touch "$SEEN_FILE"

# Get current unread notification IDs
CURRENT_IDS=$(echo "$NOTIFICATIONS" | jq -r '.[] | select(.readAt == null) | .id' 2>/dev/null)

# Check for new notifications and send native alerts
for id in $CURRENT_IDS; do
    if ! grep -q "^$id$" "$SEEN_FILE" 2>/dev/null; then
        # Get notification details
        NOTIF=$(echo "$NOTIFICATIONS" | jq -r ".[] | select(.id == \"$id\")" 2>/dev/null)
        ACTOR=$(echo "$NOTIF" | jq -r '.actor.name // "Someone"')
        TYPE=$(echo "$NOTIF" | jq -r '.type')
        INBOX_URL=$(echo "$NOTIF" | jq -r '.inboxUrl // "https://linear.app/inbox"')
        NOTIF_TITLE=$(echo "$NOTIF" | jq -r '.title // ""')
        NOTIF_SUBTITLE=$(echo "$NOTIF" | jq -r '.subtitle // ""')

        # Check if it's an issue notification
        ISSUE_ID=$(echo "$NOTIF" | jq -r '.issue.identifier // ""')
        ISSUE_TITLE=$(echo "$NOTIF" | jq -r '.issue.title // ""')
        ISSUE_URL=$(echo "$NOTIF" | jq -r '.issue.url // ""')

        # Check if it's a project notification
        PROJECT_NAME=$(echo "$NOTIF" | jq -r '.project.name // ""')
        PROJECT_URL=$(echo "$NOTIF" | jq -r '.project.url // ""')

        # Determine the URL to use (prefer specific URL, fall back to inboxUrl)
        if [ -n "$ISSUE_URL" ] && [ "$ISSUE_URL" != "null" ]; then
            NOTIF_URL="$ISSUE_URL"
        elif [ -n "$PROJECT_URL" ] && [ "$PROJECT_URL" != "null" ]; then
            NOTIF_URL="$PROJECT_URL"
        else
            # For feed summary (Pulse) notifications, strip the /notification/... suffix
            if [ "$TYPE" = "feedSummaryGenerated" ]; then
                NOTIF_URL=$(echo "$INBOX_URL" | sed 's|/notification/.*$||')
            else
                NOTIF_URL="$INBOX_URL"
            fi
        fi

        # Format title based on type
        case "$TYPE" in
            "issueAssignedToYou") TITLE="$ACTOR assigned you to $ISSUE_ID" ;;
            "issueCommentMention"|"issueMention") TITLE="$ACTOR mentioned you in $ISSUE_ID" ;;
            "issueComment"|"issueNewComment") TITLE="New comment on $ISSUE_ID" ;;
            "feedSummaryGenerated")
                TITLE="Weekly Pulse"
                ISSUE_TITLE="$NOTIF_SUBTITLE"
                ;;
            "projectUpdateCreated"|"projectUpdateMentionPrompt")
                TITLE="Project Update: $PROJECT_NAME"
                ISSUE_TITLE="$NOTIF_SUBTITLE"
                ;;
            *)
                # Use Linear's built-in title/subtitle if available
                if [ -n "$NOTIF_TITLE" ] && [ "$NOTIF_TITLE" != "null" ]; then
                    TITLE="$NOTIF_TITLE"
                    ISSUE_TITLE="$NOTIF_SUBTITLE"
                elif [ -n "$ISSUE_ID" ]; then
                    TITLE="Linear: $ISSUE_ID"
                else
                    TITLE="Linear Notification"
                    ISSUE_TITLE="$NOTIF_SUBTITLE"
                fi
                ;;
        esac

        # Send native notification (only encode & to avoid breaking URL params)
        SAFE_TITLE=$(echo "$TITLE" | sed 's/&/and/g')
        SAFE_BODY=$(echo "${ISSUE_TITLE:-New notification}" | sed 's/&/and/g')
        open -g "swiftbar://notify?plugin=linear-notifications&title=$SAFE_TITLE&body=$SAFE_BODY&href=$NOTIF_URL" 2>/dev/null

        # Mark as seen
        echo "$id" >> "$SEEN_FILE"
    fi
done

# Keep only recent IDs in cache (last 100)
tail -100 "$SEEN_FILE" > "$SEEN_FILE.tmp" && mv "$SEEN_FILE.tmp" "$SEEN_FILE"

# Menu bar header
if [ "$UNREAD_COUNT" -gt 0 ]; then
    echo "$UNREAD_COUNT $LINEAR_ICON_TITLE | $LINEAR_ICON_PARAMS_ACTIVE"
else
    echo "$LINEAR_ICON_TITLE | $LINEAR_ICON_PARAMS_IDLE"
fi

echo "---"
echo "Linear Notifications | href=https://linear.app/inbox"
echo "---"

if [ "$UNREAD_COUNT" -eq 0 ] || [ "$UNREAD_COUNT" = "null" ]; then
    echo "No unread notifications"
    exit 0
fi

# Process each unread notification
echo "$NOTIFICATIONS" | jq -c '.[] | select(.readAt == null)' | while read -r notification; do
    TYPE=$(echo "$notification" | jq -r '.type')
    ACTOR=$(echo "$notification" | jq -r '.actor.name // "Someone"')
    NOTIF_ID=$(echo "$notification" | jq -r '.id')
    INBOX_URL=$(echo "$notification" | jq -r '.inboxUrl // "https://linear.app/inbox"')
    NOTIF_TITLE=$(echo "$notification" | jq -r '.title // ""')
    NOTIF_SUBTITLE=$(echo "$notification" | jq -r '.subtitle // ""')

    # Issue details
    ISSUE_TITLE=$(echo "$notification" | jq -r '.issue.title // empty')
    ISSUE_ID=$(echo "$notification" | jq -r '.issue.identifier // empty')
    ISSUE_URL=$(echo "$notification" | jq -r '.issue.url // empty')

    # Project details
    PROJECT_NAME=$(echo "$notification" | jq -r '.project.name // empty')
    PROJECT_URL=$(echo "$notification" | jq -r '.project.url // empty')

    # Determine the URL to use
    if [ -n "$ISSUE_URL" ] && [ "$ISSUE_URL" != "null" ]; then
        CLICK_URL="$ISSUE_URL"
    elif [ -n "$PROJECT_URL" ] && [ "$PROJECT_URL" != "null" ]; then
        CLICK_URL="$PROJECT_URL"
    else
        # For feed summary (Pulse) notifications, strip the /notification/... suffix
        if [ "$TYPE" = "feedSummaryGenerated" ]; then
            CLICK_URL=$(echo "$INBOX_URL" | sed 's|/notification/.*$||')
        else
            CLICK_URL="$INBOX_URL"
        fi
    fi

    # Format notification text based on type
    case "$TYPE" in
        "issueAssignedToYou")
            TEXT="$ACTOR assigned you to $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueCommentMention")
            TEXT="$ACTOR mentioned you in $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueComment")
            TEXT="$ACTOR commented on $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueStatusChanged")
            TEXT="Status changed on $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issuePriorityChanged")
            TEXT="Priority changed on $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueNewComment")
            TEXT="New comment on $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueSubscribed")
            TEXT="You were subscribed to $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "issueMention")
            TEXT="$ACTOR mentioned you in $ISSUE_ID"
            SUBTITLE="$ISSUE_TITLE"
            ;;
        "feedSummaryGenerated")
            TEXT="Weekly Pulse"
            SUBTITLE="$NOTIF_SUBTITLE"
            ;;
        "projectUpdateCreated")
            TEXT="Project update: $PROJECT_NAME"
            SUBTITLE="$NOTIF_SUBTITLE"
            ;;
        "projectUpdateMentionPrompt")
            TEXT="Update prompt: $PROJECT_NAME"
            SUBTITLE="$NOTIF_SUBTITLE"
            ;;
        *)
            # Use Linear's built-in title if available
            if [ -n "$NOTIF_TITLE" ] && [ "$NOTIF_TITLE" != "null" ]; then
                TEXT="$NOTIF_TITLE"
                SUBTITLE="$NOTIF_SUBTITLE"
            elif [ -n "$ISSUE_ID" ]; then
                TEXT="$TYPE: $ISSUE_ID"
                SUBTITLE="$ISSUE_TITLE"
            else
                TEXT="$TYPE"
                SUBTITLE="$NOTIF_SUBTITLE"
            fi
            ;;
    esac

    # Truncate subtitle if too long
    SHORT_SUBTITLE=$(echo "$SUBTITLE" | cut -c1-40)
    if [ ${#SUBTITLE} -gt 40 ]; then
        SHORT_SUBTITLE="$SHORT_SUBTITLE..."
    fi

    # Output menu item
    echo "$TEXT | bash=$0 param1=--open param2=$NOTIF_ID param3=$CLICK_URL terminal=false refresh=true"
    if [ -n "$SHORT_SUBTITLE" ]; then
        echo "--$SHORT_SUBTITLE | bash=$0 param1=--open param2=$NOTIF_ID param3=$CLICK_URL terminal=false refresh=true size=12 color=gray"
    fi
done

echo "---"
echo "Refresh | refresh=true"
echo "Mark all as read | bash=$0 param1=--mark-all terminal=false refresh=true"
echo "Open Linear | href=https://linear.app"
echo "---"
echo "Reset API Key | bash=$0 param1=--reset terminal=true refresh=true"
