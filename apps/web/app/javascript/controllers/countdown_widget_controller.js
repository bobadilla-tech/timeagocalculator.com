import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title", "date", "time", "timezone",
    "bgColor", "bgColorHex",
    "titleColor", "titleColorHex",
    "numColor", "numColorHex",
    "labelColor", "labelColorHex",
    "radius", "radiusLabel",
    "shadow", "layout", "font", "fontScale",
    "showDate", "dateFormat", "unit",
    "preview", "previewPane", "embedPane",
    "previewTab", "embedTab", "embedCode"
  ]

  connect() {
    // Auto-detect browser timezone
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
    const tzOption = this.timezoneTarget.querySelector(`option[value="${tz}"]`)
    if (tzOption) this.timezoneTarget.value = tz

    // Default date to tomorrow
    if (!this.dateTarget.value) {
      this.dateTarget.value = this.tomorrowISO()
    }

    this.update()
  }

  disconnect() {
    clearInterval(this.tickInterval)
  }

  update() {
    const cfg = this.readConfig()
    this.radiusLabelTarget.textContent = `${cfg.radius}px`
    this.previewTarget.innerHTML = this.renderWidget(cfg)
    this.startTick(cfg)
    this.embedCodeTarget.value = this.buildEmbedCode(cfg)
    this.loadFont(cfg.font)
  }

  // ── Color sync ──────────────────────────────────────────────────────────────

  syncBgPicker()    { this.bgColorHexTarget.value    = this.bgColorTarget.value;    this.update() }
  syncBgHex()       { if (this.validHex(this.bgColorHexTarget.value))    { this.bgColorTarget.value    = this.bgColorHexTarget.value.trim();    this.update() } }
  syncTitlePicker() { this.titleColorHexTarget.value = this.titleColorTarget.value; this.update() }
  syncTitleHex()    { if (this.validHex(this.titleColorHexTarget.value)) { this.titleColorTarget.value = this.titleColorHexTarget.value.trim(); this.update() } }
  syncNumPicker()   { this.numColorHexTarget.value   = this.numColorTarget.value;   this.update() }
  syncNumHex()      { if (this.validHex(this.numColorHexTarget.value))   { this.numColorTarget.value   = this.numColorHexTarget.value.trim();   this.update() } }
  syncLabelPicker() { this.labelColorHexTarget.value = this.labelColorTarget.value; this.update() }
  syncLabelHex()    { if (this.validHex(this.labelColorHexTarget.value)) { this.labelColorTarget.value = this.labelColorHexTarget.value.trim(); this.update() } }

  validHex(v) { return /^#[0-9a-fA-F]{3,6}$/.test(v?.trim()) }

  // ── Tab switching ────────────────────────────────────────────────────────────

  showPreview() {
    this.previewPaneTarget.classList.remove("hidden")
    this.embedPaneTarget.classList.add("hidden")
    this.previewTabTarget.classList.add("border-b-2", "border-blue-600", "text-blue-600")
    this.previewTabTarget.classList.remove("text-slate-500", "border-transparent")
    this.embedTabTarget.classList.remove("border-b-2", "border-blue-600", "text-blue-600")
    this.embedTabTarget.classList.add("text-slate-500", "border-transparent")
  }

  showEmbed() {
    this.previewPaneTarget.classList.add("hidden")
    this.embedPaneTarget.classList.remove("hidden")
    this.embedTabTarget.classList.add("border-b-2", "border-blue-600", "text-blue-600")
    this.embedTabTarget.classList.remove("text-slate-500", "border-transparent")
    this.previewTabTarget.classList.remove("border-b-2", "border-blue-600", "text-blue-600")
    this.previewTabTarget.classList.add("text-slate-500", "border-transparent")
  }

  // ── Config reader ─────────────────────────────────────────────────────────────

  readConfig() {
    const dateVal  = this.dateTarget.value  || this.tomorrowISO()
    const timeVal  = this.timeTarget.value  || "00:00"
    const targetDate = new Date(`${dateVal}T${timeVal}:00`)

    return {
      title:       this.titleTarget.value || "My Countdown",
      targetDate,
      dateStr:     dateVal,
      timeStr:     timeVal,
      timezone:    this.timezoneTarget.value || "UTC",
      bg:          this.bgColorTarget.value,
      titleColor:  this.titleColorTarget.value,
      numColor:    this.numColorTarget.value,
      labelColor:  this.labelColorTarget.value,
      radius:      parseInt(this.radiusTarget.value) || 20,
      shadow:      this.shadowTarget.value,
      font:        this.fontTarget.value,
      fontScale:   parseInt(this.fontScaleTarget.value) || 100,
      layout:      this.layoutTarget.value,
      showDate:    this.showDateTarget.value !== "false",
      dateFormat:  this.dateFormatTarget.value,
      units:       this.unitTargets.filter(cb => cb.checked).map(cb => cb.value),
    }
  }

  // ── Widget renderer (mirrors widgets/countdown.html.erb) ──────────────────────

  renderWidget(cfg) {
    const shadowMap = {
      none:   "none",
      soft:   "0 2px 8px rgba(0,0,0,0.15)",
      medium: "0 4px 16px rgba(0,0,0,0.25)",
      strong: "0 8px 32px rgba(0,0,0,0.45)",
    }
    const scale      = cfg.fontScale
    const shadow     = shadowMap[cfg.shadow] || "none"
    const fontFamily = cfg.font === "system"
      ? "system-ui, -apple-system, sans-serif"
      : `'${cfg.font}', sans-serif`

    const numSize   = Math.round(scale * 0.52)
    const titleSize = Math.round(scale * 0.22)
    const dateSize  = Math.round(scale * 0.12)
    const labelSize = Math.max(10, Math.round(scale * 0.1))
    const unitWidth = Math.round(scale * 0.6)
    const gap       = Math.round(scale * 0.24)
    const padV      = Math.round(scale * 0.24)
    const padH      = Math.round(scale * 0.4)

    const titleHtml = cfg.title
      ? `<h2 style="color:${cfg.titleColor};font-size:${titleSize}px;font-weight:700;margin-bottom:4px;letter-spacing:-0.01em;">🕐 ${this.esc(cfg.title)}</h2>`
      : ""

    const dateHtml = cfg.showDate
      ? `<p style="color:${cfg.labelColor};font-size:${dateSize}px;margin-bottom:14px;opacity:0.85;">${this.formatDate(cfg.targetDate, cfg.dateFormat)}</p>`
      : ""

    const unitsHtml = (cfg.units.length ? cfg.units : ["days", "hours", "minutes", "seconds"]).map(u => `
      <div style="min-width:${unitWidth}px;text-align:center;">
        <div id="pw-${u}" style="color:${cfg.numColor};font-size:${numSize}px;font-weight:700;line-height:1;font-variant-numeric:tabular-nums;">0</div>
        <div style="color:${cfg.labelColor};font-size:${labelSize}px;text-transform:uppercase;letter-spacing:0.1em;margin-top:5px;font-weight:500;">${u}</div>
      </div>`).join("")

    return `<div style="background:${cfg.bg};border-radius:${cfg.radius}px;box-shadow:${shadow};padding:${padV}px ${padH}px;font-family:${fontFamily};width:100%;min-height:140px;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;">
      ${titleHtml}
      ${dateHtml}
      <div style="display:flex;gap:${gap}px;align-items:flex-start;margin-bottom:14px;">${unitsHtml}</div>
      <p style="color:rgba(255,255,255,0.35);font-size:10px;margin-top:4px;font-family:system-ui,sans-serif;">
        Countdown widget powered by <a href="https://timeagocalculator.com" style="color:rgba(255,255,255,0.45);">TimeAgoCalculator.com</a>
      </p>
    </div>`
  }

  // ── Countdown tick for preview ────────────────────────────────────────────────

  startTick(cfg) {
    clearInterval(this.tickInterval)
    const units    = cfg.units.length ? cfg.units : ["days", "hours", "minutes", "seconds"]
    const targetMs = cfg.targetDate.getTime()

    const tick = () => {
      const diff = Math.max(0, targetMs - Date.now())
      const s    = Math.floor(diff / 1000)
      const d    = Math.floor(s / 86400)
      const h    = Math.floor((s % 86400) / 3600)
      const m    = Math.floor((s % 3600) / 60)
      const sec  = s % 60
      const set  = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v }
      const pad  = n => String(n).padStart(2, "0")

      if (units.includes("days"))    set("pw-days",    d)
      if (units.includes("hours"))   set("pw-hours",   pad(h))
      if (units.includes("minutes")) set("pw-minutes", pad(m))
      if (units.includes("seconds")) set("pw-seconds", pad(sec))
    }

    tick()
    this.tickInterval = setInterval(tick, 1000)
  }

  // ── Embed code builder ────────────────────────────────────────────────────────

  buildEmbedCode(cfg) {
    const p = new URLSearchParams({
      title:        cfg.title,
      date:         cfg.dateStr,
      time:         cfg.timeStr,
      tz:           cfg.timezone,
      bg:           cfg.bg,
      title_color:  cfg.titleColor,
      num_color:    cfg.numColor,
      label_color:  cfg.labelColor,
      radius:       cfg.radius,
      shadow:       cfg.shadow,
      font:         cfg.font,
      scale:        cfg.fontScale,
      layout:       cfg.layout,
      show_date:    cfg.showDate,
      date_format:  cfg.dateFormat,
      units:        cfg.units.join(","),
    })
    const origin = window.location.origin
    const src    = `${origin}/widget/countdown?${p.toString()}`
    return `<iframe\n  src="${src}"\n  width="100%"\n  height="200"\n  frameborder="0"\n  style="border: none; overflow: hidden;"\n  scrolling="no"\n></iframe>`
  }

  // ── Font loader ───────────────────────────────────────────────────────────────

  loadFont(fontName) {
    if (fontName === "system" || document.querySelector(`link[data-widget-font="${fontName}"]`)) return
    const link = document.createElement("link")
    link.rel       = "stylesheet"
    link.href      = `https://fonts.googleapis.com/css2?family=${fontName.replace(" ", "+")}:wght@400;700&display=swap`
    link.dataset.widgetFont = fontName
    document.head.appendChild(link)
  }

  // ── Utilities ─────────────────────────────────────────────────────────────────

  tomorrowISO() {
    const d = new Date()
    d.setDate(d.getDate() + 1)
    return d.toISOString().split("T")[0]
  }

  formatDate(date, fmt) {
    if (!date || isNaN(date)) return ""
    if (fmt === "short")   return date.toLocaleDateString("en-US", { month: "numeric", day: "numeric", year: "numeric" })
    if (fmt === "numeric") return date.toISOString().split("T")[0]
    return date.toLocaleDateString("en-US", { month: "long", day: "numeric", year: "numeric" })
  }

  esc(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
