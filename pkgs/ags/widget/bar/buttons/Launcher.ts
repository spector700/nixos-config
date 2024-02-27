import PanelButton from "../PanelButton"
import options from "options"

const { icon, action } = options.bar.launcher

export default () => PanelButton({
    window: "launcher",
    on_clicked: action.bind(),
    child: Widget.Box([
        Widget.Icon({
            class_name: icon.colored.bind().as(c => c ? "colored" : ""),
            visible: icon.icon.bind().as(v => !!v),
            icon: icon.icon.bind(),
        }),
    ]),
})
