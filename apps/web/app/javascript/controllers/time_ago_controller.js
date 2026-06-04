import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInput"]

  preview() {
    // Client-side instant preview — form GET submission provides the canonical result
    const val = this.dateInputTarget.value
    if (!val) return
    // Let the browser handle form submission on change for accuracy
    this.element.closest("form").requestSubmit()
  }
}
