import Mpris from "resource:///com/github/Aylur/ags/service/mpris.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import HoverRevealer from "../../misc/HoverRevealer.js";
import * as mpris from "../../misc/mpris.js";
import options from "../../options.js";

export const getPlayer = (name = options.mpris.preferred.value) =>
  Mpris.getPlayer(name) || Mpris.players[0] || null;

/**
 * @param {Object} o
 * @param {import('types/service/mpris').MprisPlayer} o.player
 * @param {import('../../misc/HoverRevealer').HoverRevealProps['direction']=} o.direction
 */
const Indicator = ({ player, direction = "right" }) =>
  HoverRevealer({
    class_name: `media panel-button ${player.name}`,
    direction,
    indicator: mpris.PlayerIcon(player),
    child: Widget.Label({
      vexpand: true,
      truncate: "end",
      max_width_chars: 40,
      label: player
        .bind("track_title")
        .transform(
          () => `${player.track_artists.join(", ")} - ${player.track_title}`,
        ),
    }),
  });

/**
 * @param {Object} o
 * @param {import('../../misc/HoverRevealer').HoverRevealProps['direction']=} o.direction
 */
export default ({ direction = "right" } = {}) => {
  let current = null;

  const update = (box) => {
    const player = getPlayer();
    box.visible = !!player;

    if (!player) {
      current = null;
      return;
    }

    if (current === player) return;

    current = player;
    box.children = [Indicator({ player, direction })];
  };

  return Widget.Box()
    .hook(options.mpris.preferred, update)
    .hook(Mpris, update, "notify::players");
};
