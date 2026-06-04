import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["button"]

  copy() {
    if (!navigator.clipboard) return

    navigator.clipboard.writeText(this.textValue).then(() => {
      const original = this.buttonTarget.textContent
      this.buttonTarget.textContent = "Copied!"
      this.buttonTarget.disabled = true
      setTimeout(() => {
        this.buttonTarget.textContent = original
        this.buttonTarget.disabled = false
      }, 2000)
    })
  }
}
