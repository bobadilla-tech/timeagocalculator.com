import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["seconds"]
  static values = { base: Number, renderedAt: Number }

  connect() {
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick() {
    const elapsed = Math.floor((Date.now() - this.renderedAtValue) / 1000)
    const total = this.baseValue + elapsed
    if (this.hasSecondsTarget) {
      this.secondsTarget.textContent = String(total % 60).padStart(2, "0")
    }
  }
}
