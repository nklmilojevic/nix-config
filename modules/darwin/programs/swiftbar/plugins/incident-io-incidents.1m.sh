#!/bin/bash

# <xbar.title>incident.io Incidents</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Your Name</xbar.author>
# <xbar.desc>Shows active and recent incident.io incidents in menu bar</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>

# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>

# Use SF Symbol for icon
INCIDENT_ICON_TITLE=":dot.radiowaves.left.and.right:"
INCIDENT_ICON_PARAMS_ACTIVE="size=14 sfcolor=white"
INCIDENT_ICON_PARAMS_IDLE="size=14 sfcolor=gray"

KEYCHAIN_SERVICE="swiftbar-incident-io"
KEYCHAIN_ACCOUNT="api-key"

# Try to get token from Keychain
INCIDENT_API_KEY=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null)

if [ -z "$INCIDENT_API_KEY" ]; then
    echo "! $INCIDENT_ICON_TITLE | $INCIDENT_ICON_PARAMS_IDLE"
    echo "---"
    echo "incident.io API key not configured | color=red"
    echo "---"
    echo "Setup incident.io API Key | bash=$0 param1=--setup terminal=true refresh=true"
    echo "---"
    echo "Get API key | href=https://app.incident.io/settings/api-keys"

    # Handle setup mode
    if [ "$1" = "--setup" ]; then
        echo ""
        echo "Enter your incident.io API key (from https://app.incident.io/settings/api-keys):"
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

# Handle reset
if [ "$1" = "--reset" ]; then
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null
    echo "API key removed. Refresh to set up again."
    read -n 1
    exit 0
fi

# Handle debug - show raw API response for first incident
if [ "$1" = "--debug" ]; then
    RESPONSE=$(curl -s --get \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $INCIDENT_API_KEY" \
        --data-urlencode "page_size=1" \
        "https://api.incident.io/v2/incidents" 2>/dev/null)
    echo "=== First incident fields (looking for Slack) ==="
    echo "$RESPONSE" | jq '.incidents[0] | keys' 2>/dev/null
    echo ""
    echo "=== Slack-related fields ==="
    echo "$RESPONSE" | jq '.incidents[0] | to_entries | map(select(.key | test("slack|channel"; "i"))) | from_entries' 2>/dev/null
    echo ""
    echo "=== Full first incident ==="
    echo "$RESPONSE" | jq '.incidents[0]' 2>/dev/null
    echo ""
    echo "Press any key to close..."
    read -n 1
    exit 0
fi

# Fetch active incidents (live + triage)
RESPONSE=$(curl -s --get \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $INCIDENT_API_KEY" \
    --data-urlencode "status_category[one_of]=live" \
    --data-urlencode "status_category[one_of]=triage" \
    --data-urlencode "page_size=25" \
    "https://api.incident.io/v2/incidents" 2>/dev/null)

# Check if the request was successful
if [ $? -ne 0 ] || [ -z "$RESPONSE" ]; then
    echo "! $INCIDENT_ICON_TITLE | $INCIDENT_ICON_PARAMS_IDLE"
    echo "---"
    echo "Failed to fetch incidents | color=red"
    exit 0
fi

# Check for errors in response
ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // empty' 2>/dev/null)
if [ -n "$ERROR" ]; then
    echo "! $INCIDENT_ICON_TITLE | $INCIDENT_ICON_PARAMS_IDLE"
    echo "---"
    echo "API Error: $ERROR | color=red"
    echo "---"
    echo "Reset API Key | bash=$0 param1=--reset terminal=true refresh=true"
    exit 0
fi

# Parse incidents
INCIDENTS=$(echo "$RESPONSE" | jq -r '.incidents // []' 2>/dev/null)
INCIDENT_COUNT=$(echo "$INCIDENTS" | jq 'length' 2>/dev/null)

# Fetch recent past incidents (closed, learning, canceled, declined, merged)
PAST_RESPONSE=$(curl -s --get \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $INCIDENT_API_KEY" \
    --data-urlencode "status_category[one_of]=closed" \
    --data-urlencode "status_category[one_of]=learning" \
    --data-urlencode "status_category[one_of]=canceled" \
    --data-urlencode "status_category[one_of]=declined" \
    --data-urlencode "status_category[one_of]=merged" \
    --data-urlencode "page_size=10" \
    "https://api.incident.io/v2/incidents" 2>/dev/null)

PAST_ERROR=""
if [ $? -ne 0 ] || [ -z "$PAST_RESPONSE" ]; then
    PAST_ERROR="Failed to fetch past incidents"
    PAST_INCIDENTS="[]"
else
    PAST_ERROR=$(echo "$PAST_RESPONSE" | jq -r '.errors[0].message // empty' 2>/dev/null)
    if [ -n "$PAST_ERROR" ]; then
        PAST_INCIDENTS="[]"
    else
        PAST_INCIDENTS=$(echo "$PAST_RESPONSE" | jq -r '.incidents // []' 2>/dev/null)
    fi
fi
PAST_COUNT=$(echo "$PAST_INCIDENTS" | jq 'length' 2>/dev/null)

# Native notifications for new incidents
CACHE_DIR="${SWIFTBAR_PLUGIN_CACHE_PATH:-$HOME/.cache/swiftbar}"
mkdir -p "$CACHE_DIR"
SEEN_FILE="$CACHE_DIR/incident-io-seen-ids"
touch "$SEEN_FILE"

# Get current incident IDs
CURRENT_IDS=$(echo "$INCIDENTS" | jq -r '.[].id' 2>/dev/null)

for id in $CURRENT_IDS; do
    if ! grep -q "^$id$" "$SEEN_FILE" 2>/dev/null; then
        INC=$(echo "$INCIDENTS" | jq -r ".[] | select(.id == \"$id\")" 2>/dev/null)
        REF=$(echo "$INC" | jq -r '.reference // empty')
        NAME=$(echo "$INC" | jq -r '.name // "New incident"')
        STATUS=$(echo "$INC" | jq -r '.incident_status.name // empty')
        SLACK_TEAM_ID=$(echo "$INC" | jq -r '.slack_team_id // empty')
        SLACK_CHANNEL_ID=$(echo "$INC" | jq -r '.slack_channel_id // empty')
        PERMALINK=$(echo "$INC" | jq -r '.permalink // "https://app.incident.io"')

        # Construct Slack URL from team and channel IDs
        if [ -n "$SLACK_TEAM_ID" ] && [ "$SLACK_TEAM_ID" != "null" ] && [ -n "$SLACK_CHANNEL_ID" ] && [ "$SLACK_CHANNEL_ID" != "null" ]; then
            NOTIF_URL="slack://channel?team=$SLACK_TEAM_ID&id=$SLACK_CHANNEL_ID"
        else
            NOTIF_URL="$PERMALINK"
        fi

        if [ -n "$REF" ]; then
            NOTIF_TITLE="Incident $REF"
        else
            NOTIF_TITLE="New incident"
        fi
        if [ -n "$STATUS" ]; then
            NOTIF_TITLE="$NOTIF_TITLE ($STATUS)"
        fi

        SAFE_TITLE=$(echo "$NOTIF_TITLE" | sed 's/&/and/g')
        SAFE_BODY=$(echo "$NAME" | sed 's/&/and/g')
        open -g "swiftbar://notify?plugin=incident-io-incidents&title=$SAFE_TITLE&body=$SAFE_BODY&href=$NOTIF_URL" 2>/dev/null

        echo "$id" >> "$SEEN_FILE"
    fi
done

# Keep only recent IDs in cache (last 100)
tail -100 "$SEEN_FILE" > "$SEEN_FILE.tmp" && mv "$SEEN_FILE.tmp" "$SEEN_FILE"

# Try to get dashboard URL for quick links
DASHBOARD_URL=$(curl -s \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $INCIDENT_API_KEY" \
    "https://api.incident.io/v1/identity" 2>/dev/null | jq -r '.identity.dashboard_url // empty')
if [ -z "$DASHBOARD_URL" ] || [ "$DASHBOARD_URL" = "null" ]; then
    DASHBOARD_URL="https://app.incident.io"
fi

render_incidents() {
    local incidents="$1"
    echo "$incidents" | jq -c '.[]' | while read -r incident; do
        REF=$(echo "$incident" | jq -r '.reference // empty')
        NAME=$(echo "$incident" | jq -r '.name // "Untitled incident"')
        STATUS=$(echo "$incident" | jq -r '.incident_status.name // empty')
        CATEGORY=$(echo "$incident" | jq -r '.incident_status.category // empty')
        SEVERITY=$(echo "$incident" | jq -r '.severity.name // empty')
        PERMALINK=$(echo "$incident" | jq -r '.permalink // empty')
        SLACK_TEAM_ID=$(echo "$incident" | jq -r '.slack_team_id // empty')
        SLACK_CHANNEL_ID=$(echo "$incident" | jq -r '.slack_channel_id // empty')
        CALL_URL=$(echo "$incident" | jq -r '.call_url // empty')

        # Construct Slack URL from team and channel IDs, fall back to permalink
        if [ -n "$SLACK_TEAM_ID" ] && [ "$SLACK_TEAM_ID" != "null" ] && [ -n "$SLACK_CHANNEL_ID" ] && [ "$SLACK_CHANNEL_ID" != "null" ]; then
            LINK_URL="slack://channel?team=$SLACK_TEAM_ID&id=$SLACK_CHANNEL_ID"
        elif [ -n "$PERMALINK" ] && [ "$PERMALINK" != "null" ]; then
            LINK_URL="$PERMALINK"
        else
            LINK_URL="$DASHBOARD_URL"
        fi

        # Truncate name if too long
        SHORT_NAME=$(echo "$NAME" | cut -c1-45)
        if [ ${#NAME} -gt 45 ]; then
            SHORT_NAME="$SHORT_NAME..."
        fi

        if [ -n "$REF" ]; then
            TITLE="$REF $SHORT_NAME"
        else
            TITLE="$SHORT_NAME"
        fi

        # Style by status category
        COLOR="color=gray"
        if [ "$CATEGORY" = "live" ]; then
            COLOR="color=red"
        elif [ "$CATEGORY" = "triage" ]; then
            COLOR="color=orange"
        fi

        echo "$TITLE | href=$LINK_URL $COLOR"

        DETAILS=""
        if [ -n "$SEVERITY" ]; then
            DETAILS="Severity: $SEVERITY"
        fi
        if [ -n "$STATUS" ]; then
            if [ -n "$DETAILS" ]; then
                DETAILS="$DETAILS - Status: $STATUS"
            else
                DETAILS="Status: $STATUS"
            fi
        fi
        if [ -n "$DETAILS" ]; then
            echo "--$DETAILS | href=$LINK_URL size=12 color=gray"
        fi
        if [ -n "$PERMALINK" ] && [ "$PERMALINK" != "null" ] && [ "$PERMALINK" != "$LINK_URL" ]; then
            echo "--Open in incident.io | href=$PERMALINK size=12 color=blue"
        fi
        if [ -n "$CALL_URL" ] && [ "$CALL_URL" != "null" ]; then
            echo "--Join call | href=$CALL_URL size=12 color=blue"
        fi
    done
}

# Menu bar header
if [ "$INCIDENT_COUNT" -gt 0 ]; then
    echo "$INCIDENT_COUNT $INCIDENT_ICON_TITLE | $INCIDENT_ICON_PARAMS_ACTIVE"
else
    echo "$INCIDENT_ICON_TITLE | $INCIDENT_ICON_PARAMS_IDLE"
fi

echo "---"
echo "Active Incidents | href=$DASHBOARD_URL"
echo "---"

if [ "$INCIDENT_COUNT" -eq 0 ] || [ "$INCIDENT_COUNT" = "null" ]; then
    echo "No active incidents"
else
    render_incidents "$INCIDENTS"
fi

echo "---"
echo "Recent Incidents | href=$DASHBOARD_URL"
echo "---"

if [ -n "$PAST_ERROR" ]; then
    echo "Past incidents error: $PAST_ERROR | color=red"
elif [ "$PAST_COUNT" -eq 0 ] || [ "$PAST_COUNT" = "null" ]; then
    echo "No recent incidents"
else
    render_incidents "$PAST_INCIDENTS"
fi

echo "---"
echo "Refresh | refresh=true"
echo "Open incident.io | href=$DASHBOARD_URL"
echo "---"
echo "Debug API Response | bash=$0 param1=--debug terminal=true"
echo "Reset API Key | bash=$0 param1=--reset terminal=true refresh=true"
