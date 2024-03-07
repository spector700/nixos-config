import PopupWindow from "widget/PopupWindow"
import options from "options"
import AiService from "service/aiservice"
import Gtk from "gi://Gtk"
import Gdk from "gi://Gdk"
import hljs from "highlight.js"
import { Marked } from "marked"
import { markedHighlight } from "marked-highlight"

const { bar, aiwindow  } = options
const layout = Utils.derive([bar.position, aiwindow.position], (bar, ai) =>
    `${bar}-${ai}` as const,
)

const APIS = [
    {
        name: "Assistant (Mistral)",
        // sendCommand: geminiSendMessage,
        // contentWidget: geminiView,
        // commandBar: geminiCommands,
        // tabIcon: geminiTabIcon,
        placeholderText: "Message Mistral...",
    },
]
// The API to use
const currentApiId = 0

const WebKit2 = (await import("gi://WebKit2?=4.1")).default
const WebView = Widget.subclass(WebKit2.WebView, "AgsWebiew")
const TextView = Widget.subclass(Gtk.TextView, "AgsTextView")


const styleString = Utils.readFile(`${TMP}/highlight.css`)
const stylesheet = new WebKit2.UserStyleSheet(styleString, 0, 0, null, null)

const parser = new Marked(
    markedHighlight({
        langPrefix: "hljs language-",
        highlight(code, lang) {
            const language = hljs.getLanguage(lang) ? lang : "plaintext"
            return hljs.highlight(code, { language }).value
        },
    }),
)
// Override the code block rendering to apply syntax highlighting
const renderer = {
    code(code, language) {
        language ||= "plaintext"
        const encoded = encodeURIComponent(code)
        return `
        <div class="code">
            <div class="code-header"><span data-language="${language}">${language}</span><button onClick="copyCode(this, '${encoded}')">Copy</button></div>
            <pre><code>${code}</code></pre>
        </div>`
    },
}

parser.use({ renderer })

const MessageContent = (msg, scrollable) => {
    const view = WebView({
        class_name: "ai-msg-content",
        hexpand: true,

    })
        .hook(msg, (view: { load_html: (arg0: string, arg1: string) => void }) => {
            const content = `<script>
                function copyCode(button, encodedCode) {
                  const decodedCode = decodeURIComponent(encodedCode);
                  const tempElement = document.createElement('pre');
                  tempElement.innerHTML = decodedCode;
                  navigator.clipboard.writeText(tempElement.innerText);
                  button.innerText = 'Copied';
                  setTimeout(() => button.innerText = 'Copy', 2000);
                }</script>` + parser.parse(msg.content)
            view.load_html(content, "file://")
        }, "notify::content")
        .on("load-changed",
            (view: WebKit2.WebView, event: WebKit2.LoadEvent) => {
                if (event === 3) {
                    view.evaluate_javascript("document.body.scrollHeight",
                        -1, null, null, null, (view, result) => {
                            const height = view.evaluate_javascript_finish(result)?.to_int32() || -1
                            view.get_parent().css = `min-height: ${height}px;`
                            const adjustment = scrollable.get_vadjustment()
                            adjustment.set_value(adjustment.get_upper() - adjustment.get_page_size())
                        })
                }
            })
    // HACK: evil way to disable context menu
        .on("context-menu", (view, menu) => {
            menu.remove_all()
        })
        .on("decide-policy", (view, decision, type) => {
            if (type !== 0) {
                decision.ignore()
                return
            }
            const uri = decision.get_request().get_uri()
            if (uri === "file:///") {
                decision.use()
                return
            }
            decision.ignore()
            Utils.execAsync(["xdg-open", uri])
        })
    view.get_settings().set_javascript_can_access_clipboard(true)
    view.get_settings().set_enable_write_console_messages_to_stdout(true)
    view.get_user_content_manager().add_style_sheet(stylesheet)
    // HACK: style context is only accessable after the widget was added to the
    // hierachy, so i do this to set the color once.
    view.on("realize", () => {
        const bgCol = view.get_style_context().get_property("background-color", Gtk.StateFlags.NORMAL)
        view.set_background_color(bgCol)
    })

    return Widget.Box({
        css: "padding: 1px",
        children: [view],
    })
}

const Message = (msg, scrollable) => Widget.Box({
    class_name: `ai-message ${msg.role}`,
    vertical: true,
    children: [
        Widget.Label({
            hpack: "fill",
            xalign: 0,
            wrap: true,
            class_name: `ai-role ${msg.role}`,
            useMarkup: true,
            label: msg.role === "user" ? "You" :
                // Capitalize the first letter
                AiService.model.charAt(0).toUpperCase() + AiService.model.slice(1),
        }),
        MessageContent(msg, scrollable),
    ],
})

function sendMessage(textview) {
    const buffer = textview.get_buffer()
    const [start, end] = buffer.get_bounds()
    const text = buffer.get_text(start, end, true)
    if (!text || text.length === 0 || text === APIS[currentApiId].placeholderText)
        return
    if (text.startsWith("/system"))
        AiService.setSystemMessage(text.substring(7))

    else
        AiService.send(text)

    buffer.set_text("", -1)
}

const TextEntry = () => {
    const placeholder = `<span foreground="gray">${APIS[currentApiId].placeholderText}</span>`
    const buffer = new Gtk.TextBuffer()

    buffer.insert_markup(buffer.get_start_iter(), placeholder, -1)

    const textview = TextView({
        wrap_mode: Gtk.WrapMode.WORD_CHAR,
        hexpand: true,
        buffer: buffer,
        css: "background: none",
    })
        .on("focus-in-event", () => {
            const [start, end] = buffer.get_bounds()
            const text = buffer.get_text(start, end, true)
            if (text === APIS[currentApiId].placeholderText)
                buffer.set_text("", -1)
        })
        .on("focus-out-event", () => {
            const [start, end] = buffer.get_bounds()
            const text = buffer.get_text(start, end, true)
            if (text === "")
                buffer.insert_markup(buffer.get_start_iter(), placeholder, -1)
        })
        .on("key-press-event", (entry, event) => {
            const keyval = event.get_keyval()[1]
            // Send on enter but no when holding shift
            if (keyval === Gdk.KEY_Return && event.get_state()[1] !== Gdk.ModifierType.SHIFT_MASK) {
                sendMessage(entry)
                return true
            }
        })

    return Widget.Scrollable({
        child: textview,
        class_name: "text-box-scrollable",
        max_content_height: 200,
        propagate_natural_height: true,
        vscroll: "automatic",
        hscroll: "never",
    })
}

const Settings = () => Widget.Box({
    vertical: true,
    class_name: "ai-window-container",
    css: "min-width: 600px; min-height: 550px",
    children: [
        Widget.Label({
            class_name: "model-label",
            label: AiService.model,
        }),
        Widget.Scrollable({
            vexpand: true,
            hscroll: "never",
            class_name: "ai-response-scrollable",
            child: Widget.Box({ vertical: true })
                .hook(AiService, (box, idx) => {
                    const msg = AiService.messages[idx]
                    if (!msg)
                        return
                    const msgWidget = Message(msg, box.get_parent())
                    box.add(msgWidget)
                }, "newMsg")
                .hook(AiService, box => {
                    box.children = []
                }, "clear"),

        }),
        Widget.Box({
            spacing: 5,
            class_name: "ai-entry-box",
            children: [
                TextEntry(),
                Widget.Button({
                    class_name: "ai-send-button",
                    label: "󰒊",
                    on_clicked: btn => {
                        const textview = btn.get_parent().children[0].child
                        sendMessage(textview)
                    },
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
