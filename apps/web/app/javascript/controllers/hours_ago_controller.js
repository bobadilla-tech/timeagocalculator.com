import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["date", "time", "hours", "minutes", "result", "table", "format"]
  static values = { now: String }

  connect() {
    // initial render of the 1..100 table based on server time
    this.renderTable()
  }

  parseBase() {
    const date = this.dateTarget.value
    const time = this.timeTarget.value
    if (date && time) {
      // e.g. 2026-06-05 and 08:51 -> 2026-06-05T08:51
      return new Date(`${date}T${time}`)
    }

    // fallback to server-provided now
    return new Date(this.nowValue)
  }

  calculate() {
    const base = this.parseBase()
    const hrs = parseInt(this.hoursTarget.value || "0", 10)
    const mins = parseInt(this.minutesTarget.value || "0", 10)

    const deltaMs = (hrs * 60 + mins) * 60 * 1000
    const result = new Date(base.getTime() - deltaMs)

    this.showResult(result)
  }

  showResult(dt) {
    const use12 = this.formatTarget.value === "12"
    const options = { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit', hour12: use12 }
    const formatted = new Intl.DateTimeFormat(undefined, options).format(dt)

    this.resultTarget.innerHTML = `<p class="text-lg font-semibold">Result: ${formatted}</p>`
  }

  renderTable() {
    const base = new Date(this.nowValue)
    const use12 = (this.formatTarget && this.formatTarget.value === "12")
    const options = { hour: 'numeric', minute: '2-digit', hour12: use12 }

    let html = '<table class="w-full text-sm"><thead><tr><th class="text-left">Time Ago</th><th class="text-left">Time</th><th class="text-left">Date</th></tr></thead><tbody>'
    for (let i = 1; i <= 100; i++) {
      const dt = new Date(base.getTime() - i * 3600 * 1000)
      const time = new Intl.DateTimeFormat(undefined, options).format(dt)
      const date = dt.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
      html += `<tr><td class="py-1">${i} hour${i>1?'s':''}</td><td class="py-1">${time}</td><td class="py-1">${date}</td></tr>`
    }
    html += '</tbody></table>'

    this.tableTarget.innerHTML = html
  }
}
