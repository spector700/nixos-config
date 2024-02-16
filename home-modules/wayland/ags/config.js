"use strict";

import Applauncher from "./js/applauncher/Applauncher.js";
import Dashboard from "./js/dashboard/Dashboard.js";
import Lockscreen from "./js/lockscreen/Lockscreen.js";
import Notifications from "./js/notifications/Notifications.js";
import OSD from "./js/osd/OSD.js";
import Overview from "./js/overview/Overview.js";
import PowerMenu from "./js/powermenu/PowerMenu.js";
import QuickSettings from "./js/quicksettings/QuickSettings.js";
import ScreenCorners from "./js/screencorner/ScreenCorners.js";
import TopBar from "./js/bar/TopBar.js";
import Verification from "./js/powermenu/Verification.js";
import { init } from "./js/settings/setup.js";
import { forMonitors } from "./js/utils.js";
import options from "./js/options.js";

const windows = () => [
  forMonitors(Lockscreen),
  forMonitors(Notifications),
  forMonitors(OSD),
  forMonitors(ScreenCorners),
  forMonitors(TopBar),
  Applauncher(),
  Dashboard(),
  Overview(),
  PowerMenu(),
  QuickSettings(),
  Verification(),
];

export default {
  onConfigParsed: init,
  stackTraceOnError: true,
  windows: windows().flat(1),
  maxStreamVolume: 1.05,
  cacheNotificationActions: false,
  closeWindowDelay: {
    quicksettings: options.transition.value,
    dashboard: options.transition.value,
  },
};
