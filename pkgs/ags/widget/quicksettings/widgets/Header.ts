import type Gtk from "gi://Gtk?version=3.0"
import icons from "lib/icons"
import { uptime } from "lib/variables"
import options from "options"

const battery = await Service.import("battery")
const { image, size } = options.quicksettings.avatar

function up(up: number) {
    const h = Math.floor(up / 60)
    const m = Math.floor(up % 60)
    return `${h}h ${m < 10 ? "0" + m : m}m`
}

const Avatar = () => Widget.Box({
    class_name: "avatar",
    css: Utils.merge([image.bind(), size.bind()], (img, size) => `
        min-width: ${size}px;
        min-height: ${size}px;
        background-image: url('${img}');
        background-size: cover;
    `),
})

export const Header = () => Widget.Box<Gtk.Widget>(
    { class_name: "header horizontal" },
    Avatar(),
    Widget.Box({
        vertical: true,
        vpack: "center",
        children: [
            // Only add widget if the battery is available
            ...(battery.available ? [
                Widget.Box([
                    Widget.Icon({ icon: battery.bind("icon_name") }),
                    Widget.Label({ label: battery.bind("percent").as(p => `${p}%`) }),
                ]),
            ] : []),
            Widget.Label({ label: "Uptime" }),
            Widget.Box([
                Widget.Icon({ icon: icons.ui.time }),
                Widget.Label({ label: uptime.bind().as(up) }),
            ]),
        ],
    }),
    Widget.Box({ hexpand: true }),
    Widget.Button({
        vpack: "center",
        child: Widget.Icon(icons.ui.settings),
        on_clicked: () => {
            App.closeWindow("settings-dialog")
            App.openWindow("settings-dialog")
        },
    }),
)
