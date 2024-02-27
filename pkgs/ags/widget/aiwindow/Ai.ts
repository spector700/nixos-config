import PopupWindow from "widget/PopupWindow"
import options from "options"

const { bar, aiwindow  } = options
const layout = Utils.derive([bar.position, aiwindow.position], (bar, ai) =>
    `${bar}-${ai}` as const,
)

const Settings = () => Widget.Box({
    vertical: true,
    class_name: "AiWindow vertical",
    children: [
        Widget.Box({
            class_name: "sliders-box vertical",
            vertical: true,
            children: [
                Widget.Button({
                    child: Widget.Label("click me!"),
                    onPrimaryClick: () => print("echo hello"),
                }),
            ],
        }),
    ],
})

const AiWindow = () => PopupWindow({
    name: "aiwindow",
    exclusivity: "exclusive",
    transition: bar.position.bind().as(pos => pos === "top" ? "slide_down" : "slide_up"),
    layout: layout.value,
    child: Settings(),
})

export function setupAiWindowSettings() {
    App.addWindow(AiWindow())
    layout.connect("changed", () => {
        App.removeWindow("aiwindow")
        App.addWindow(AiWindow())
    })
}
