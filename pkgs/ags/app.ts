import "lib/session"
import init from "lib/init"
import options from "options"
import Bar from "widget/bar/Bar"
import Overview from "widget/overview/Overview"
import PowerMenu from "widget/powermenu/PowerMenu"
import Verification from "widget/powermenu/Verification"
import NotificationPopups from "widget/notifications/NotificationPopups"
import OSD from "widget/osd/OSD"
import SettingsDialog from "widget/settings/SettingsDialog"
import { App } from "astal/gtk3"
import { forMonitors } from "lib/utils"
import { setupQuickSettings } from "widget/quicksettings/QuickSettings"
import { setupDateMenu } from "widget/datemenu/DateMenu"
import { setupAiWindowSettings } from "widget/aiwindow/AiWindow"

App.start({
    main() {
        forMonitors(Bar),
        forMonitors(NotificationPopups),
        forMonitors(OSD),
        Overview()
        PowerMenu()
        Verification()
        SettingsDialog()
    },
    // onConfigParsed: () => {
    //     setupQuickSettings()
    //     setupDateMenu()
    //     setupAiWindowSettings()
    //     init()
    // },
    // closeWindowDelay: {
    //     "overview": options.transition.value,
    //     "quicksettings": options.transition.value,
    //     "datemenu": options.transition.value,
    // },
})
