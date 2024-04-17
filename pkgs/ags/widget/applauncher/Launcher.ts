import PopupWindow, { Padding } from "widget/PopupWindow"
import icons from "lib/icons"
import options from "options"
import * as AppLauncher from "./AppLauncher"

const { width, margin } = options.launcher

function Launcher() {
    const favs = AppLauncher.Favorites()
    const applauncher = AppLauncher.Launcher()

    const entry = Widget.Entry({
        hexpand: true,
        primary_icon_name: icons.ui.search,
        on_accept: ({ text }) => {
            // if (text?.startsWith(":nx"))
            //     nix.run(text.substring(3))
            // else if (text?.startsWith(":sh"))
            //     sh.run(text.substring(3))
            if (text)
                applauncher.launchFirst()

            App.toggleWindow("launcher")
            entry.text = ""
        },
        on_change: ({ text }) => {
            text ||= ""
            favs.reveal_child = text === ""

            if (!text?.startsWith(":"))
                applauncher.filter(text)
        },
    })

    function focus() {
        entry.set_position(-1)
        entry.select_region(0, -1)
        entry.grab_focus()
        const first = layout.children.slice(2).find(child => child.get_visible())?.get_children()[0]
        entry.on("notify::has-focus", ({ hasFocus }) => {
            if (layout.children.length > 1)
                first?.toggleClassName("entry-focused", hasFocus)
        })
        favs.reveal_child = true
    }

    const layout = Widget.Box({
        css: width.bind().as(v => `min-width: ${v}pt;`),
        class_name: "launcher",
        vertical: true,
        vpack: "start",
        setup: self => self.hook(App, (_, win, visible) => {
            if (win !== "launcher")
                return

            entry.text = ""
            if (visible)
                focus()
        }),
        children: [
            Widget.Box([entry]),
            favs,
            applauncher,
        ],
    })

    return Widget.Box(
        { vertical: true, css: "padding: 1px" },
        Padding("launcher", {
            css: margin.bind().as(v => `min-height: ${v}pt;`),
            vexpand: false,
        }),
        layout,
    )
}

export default () => PopupWindow({
    name: "launcher",
    layout: "top",
    child: Launcher(),
})
