import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["betweenFields", "addFields", "modeRadio"]

  connect() {
    this.updateMode()
  }

  switchMode() {
    this.updateMode()
  }

  updateMode() {
    const checked = this.modeRadioTargets.find(r => r.checked)
    const mode    = checked ? checked.value : "between"

    this.betweenFieldsTarget.classList.toggle("hidden", mode !== "between")
    this.addFieldsTarget.classList.toggle("hidden", mode !== "add")

    // Disable inputs in the hidden panel so they are excluded from form submission
    this.setDisabled(this.betweenFieldsTarget, mode !== "between")
    this.setDisabled(this.addFieldsTarget, mode !== "add")

  }

  setDisabled(panel, disabled) {
    panel.querySelectorAll("input, select, textarea").forEach(el => {
      el.disabled = disabled
    })
  }
}
