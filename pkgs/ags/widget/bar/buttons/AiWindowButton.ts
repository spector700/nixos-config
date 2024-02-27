import PanelButton from "../PanelButton"

const bluetooth = await Service.import("bluetooth")

const AiIndicator = () => Widget.Overlay({
    class_name: "ai-button",
    passThrough: true,
    child: Widget.Icon({
        icon: "ai-symbolic",
    }),
    overlay: Widget.Label({
        hpack: "end",
        vpack: "start",
        label: bluetooth.bind("connected_devices").as(c => `${c.length}`),
    }),
})

export default () => PanelButton({
    class_name: "aiwindow panel-button",
    on_clicked: () => App.toggleWindow("aiwindow"),
    child: Widget.Box([
        AiIndicator(),
    ]),
})
