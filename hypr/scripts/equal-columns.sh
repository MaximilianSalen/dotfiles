#!/usr/bin/env bash
# Spread the tiled windows on the active workspace into equal-width columns.
#
# Dwindle is a binary tree, so a third window lands at 50/25/25 (or stacked
# under the second one) rather than an even 33/33/33, and there is no built-in
# "equalize" layoutmsg. So: flatten anything that is stacked into its own
# column, then pin each column's width from the left. Each resize moves one
# split in the tree and the rightmost column absorbs the remainder.
#
# The target width is just the mean of the current widths: dwindle always fills
# the whole usable area, so the gaps/borders/reserved-space arithmetic cancels
# out and this needs no knowledge of the monitor or the gap settings.

set -euo pipefail

tiled_on_active_workspace() {
    local ws
    ws=$(hyprctl -j activeworkspace | jq -r '.id')
    hyprctl -j clients | jq -c --argjson ws "$ws" '
        [ .[]
          | select(.workspace.id == $ws and .mapped and (.floating | not)
                   and .fullscreen == 0)
          | {address, x: .at[0], w: .size[0], h: .size[1]} ]
        | sort_by(.x)'
}

clients=$(tiled_on_active_workspace)
count=$(jq 'length' <<<"$clients")
[ "$count" -lt 2 ] && exit 0

# A window sharing an x with its left neighbour is stacked rather than beside
# it; flipping its parent split gives it a column of its own. Bounded by the
# window count, and bails out if a pass stops making progress.
for _ in $(seq "$count"); do
    columns=$(jq '[ .[].x ] | unique | length' <<<"$clients")
    [ "$columns" -eq "$count" ] && break

    stacked=$(jq -r 'group_by(.x) | map(select(length > 1)) | .[0][1].address' <<<"$clients")
    focused=$(hyprctl -j activewindow | jq -r '.address // empty')

    hyprctl --batch "dispatch focuswindow address:$stacked ; dispatch layoutmsg togglesplit" >/dev/null
    [ -n "$focused" ] && hyprctl dispatch focuswindow "address:$focused" >/dev/null

    clients=$(tiled_on_active_workspace)
    [ "$(jq '[ .[].x ] | unique | length' <<<"$clients")" -gt "$columns" ] || break
done

# Pin every column but the last; the last one takes what is left over.
batch=$(jq -r '
    (map(.w) | add / length | round) as $target
    | .[:-1]
    | map("dispatch resizewindowpixel exact \($target) \(.h),address:\(.address)")
    | join(" ; ")' <<<"$clients")

[ -n "$batch" ] && hyprctl --batch "$batch" >/dev/null
