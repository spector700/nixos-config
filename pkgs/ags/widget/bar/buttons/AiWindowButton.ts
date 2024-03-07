import PanelButton from "../PanelButton"

const AiIndicator = () => Widget.Overlay({
    class_name: "ai-button",
    passThrough: true,
    child: Widget.Icon({
        icon: "ai-symbolic",
    }),
})

export default () => PanelButton({
    class_name: "aiwindow panel-button",
    on_clicked: () => App.toggleWindow("aiwindow"),
    child: Widget.Box([
        AiIndicator(),
    ]),
})
