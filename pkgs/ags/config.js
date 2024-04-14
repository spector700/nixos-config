const main = "/tmp/ags/main.js"
const outdir = `${App.configDir}/main.ts`

try {
    await Utils.execAsync([
        "bun", "build", outdir,
        "--outfile", main,
        "--external", "resource://*",
        "--external", "gi://*",
        "--external", "file://*",
    ])

    await import(`file://${main}`)
} catch (error) {
    console.error(error)
    App.quit()
}

export { }
