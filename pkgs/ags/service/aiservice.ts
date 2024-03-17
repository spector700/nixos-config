import Service from "resource:///com/github/Aylur/ags/service.js"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import Soup from "gi://Soup?version=3.0"

export class AiMessage extends Service {
    static {
        Service.register(
            this,
            {},
            {
                content: ["string"],
                thinking: ["boolean"],
            },
        )
    }

    _role = ""
    _content = ""
    _thinking = false

    constructor(role: string, content: string, thinking: boolean = false) {
        super()
        this._role = role
        this._content = content
        this._thinking = thinking
    }

    get role() {
        return this._role
    }

    set role(role) {
        this._role = role
        this.emit("changed")
    }

    get content() {
        return this._content
    }

    set content(content) {
        this._content = content
        this.notify("content")
        this.emit("changed")
    }

    get thinking() {
        return this._thinking
    }

    set thinking(thinking) {
        this._thinking = thinking
        this.notify("thinking")
        this.emit("changed")
    }

    addDelta(delta: string) {
        if (this.thinking) {
            this.thinking = false
            this.content = delta
        } else {
            this.content += delta
        }
    }
}

const session = new Soup.Session()

class AiService extends Service {
    static {
        Service.register(this, {
            newMsg: ["int"],
            clear: [],
        })
    }

    _systemMessage = {
        role: "system",
        content: "",
    }

    _messages: AiMessage[] = []
    _decoder = new TextDecoder()
    model = "mistral"
    // url = GLib.Uri.parse("http://192.168.1.129:11434/api/chat", GLib.UriFlags.NONE)
    url = "http://192.168.1.129:11434/api/chat"

    setSystemMessage(msg: string) {
        this._systemMessage.content = msg
    }

    get messages() {
        return this._messages
    }

    get lastMessage() {
        return this.messages[this.messages.length - 1]
    }

    clear() {
        this._messages = []
        this.emit("clear")
    }

    readResponse(stream: Gio.DataInputStream, aiResponse: AiMessage) {
        stream.read_line_async(0, null, (stream, res) => {
            try {
                if (!stream)
                    return

                const [bytes] = stream.read_line_finish(res)
                const line = this._decoder.decode(bytes ?? undefined)
                if (line && line !== "") {
                    try {
                        const result = JSON.parse(line)
                        if (result.done)
                            return
                        aiResponse.addDelta(result.message.content)
                    } catch {
                        aiResponse.addDelta(line + "\n")
                    }
                }

                this.readResponse(stream, aiResponse)
            } catch (error) {
                console.log("Error reading response:", error)
            }
        })
    }

    send(msg: string) {
        this.messages.push(new AiMessage("user", msg))
        this.emit("newMsg", this.messages.length - 1)

        const messages = this.messages.map(msg => {
            const m = { role: msg.role, content: msg.content }
            return m
        })

        const aiResponse = new AiMessage("assistant", "thinking...", true)
        this.messages.push(aiResponse)
        this.emit("newMsg", this.messages.length - 1)

        const body = {
            model: this.model,
            messages:
        this._systemMessage.content !== ""
            ? [this._systemMessage, ...messages]
            : messages,
            stream: true,
        }

        const message = Soup.Message.new("POST", this.url)
        // message.request_headers.append("Authorization", "Bearer ")
        const requstBody = new TextEncoder().encode(JSON.stringify(body))
        message.set_request_body_from_bytes(
            "application/json",
            new GLib.Bytes(requstBody),
        )

        session.send_async(message, 0, null, (_, result) => {
            try {
                const stream = session.send_finish(result)
                this.readResponse(
                    new Gio.DataInputStream({
                        closeBaseStream: true,
                        baseStream: stream,
                    }),
                    aiResponse,
                )
            } catch (error) {
                console.error("Error sending message:", error)
            }
        })
    }
}

export default new AiService()
