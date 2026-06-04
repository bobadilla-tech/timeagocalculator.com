import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passwordFields", "isPublicField", "visibilityRadio"]

  connect() {
    this.updateVisibility()
  }

  setVisibility() {
    this.updateVisibility()
  }

  updateVisibility() {
    const selected = this.visibilityValue()
    const showPassword = selected === "protected"

    if (this.hasPasswordFieldsTarget) {
      this.passwordFieldsTarget.hidden = !showPassword
      if (!showPassword) {
        this.passwordFieldsTarget.querySelectorAll("input[type=password]").forEach(el => {
          el.value = ""
        })
      }
    }

    if (this.hasIsPublicFieldTarget) {
      this.isPublicFieldTarget.value = (selected === "private") ? "0" : "1"
    }
  }

  visibilityValue() {
    if (this.hasVisibilityRadioTarget) {
      const checked = this.visibilityRadioTargets.find(r => r.checked)
      return checked ? checked.value : "open"
    }
    return "open"
  }
}
