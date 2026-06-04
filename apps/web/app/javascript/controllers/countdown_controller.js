import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { targetTimestamp: Number }
  static targets = ["years", "months", "days", "hours", "minutes", "seconds"]

  connect() {
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick() {
    const now = Date.now()
    const diff = Math.max(0, this.targetTimestampValue - now)
    const totalSeconds = Math.floor(diff / 1000)

    const years   = Math.floor(totalSeconds / (365.25 * 86400))
    const rem1    = totalSeconds % Math.floor(365.25 * 86400)
    const months  = Math.floor(rem1 / (30.44 * 86400))
    const rem2    = rem1 % Math.floor(30.44 * 86400)
    const days    = Math.floor(rem2 / 86400)
    const hours   = Math.floor((rem2 % 86400) / 3600)
    const minutes = Math.floor((rem2 % 3600) / 60)
    const secs    = rem2 % 60

    if (this.hasYearsTarget)   this.yearsTarget.textContent   = years
    if (this.hasMonthsTarget)  this.monthsTarget.textContent  = months
    if (this.hasDaysTarget)    this.daysTarget.textContent    = days
    if (this.hasHoursTarget)   this.hoursTarget.textContent   = hours
    if (this.hasMinutesTarget) this.minutesTarget.textContent = minutes
    if (this.hasSecondsTarget) this.secondsTarget.textContent = String(secs).padStart(2, "0")
  }
}
