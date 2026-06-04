import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passwordFields", "isPublicField", "visibilityRadio", "publishFields"]

  connect() {
    this.updateVisibility()
  }

  setVisibility() {
    this.updateVisibility()
  }

  updateVisibility() {
    const selected = this.visibilityValue()
    const showPassword = selected === "protected"
    const showPublish  = selected !== "private"

    if (this.hasPasswordFieldsTarget) {
      this.passwordFieldsTarget.classList.toggle("hidden", !showPassword)
      if (!showPassword) {
        this.passwordFieldsTarget.querySelectorAll("input[type=password]").forEach(el => {
          el.value = ""
        })
      }
    }

    if (this.hasPublishFieldsTarget) {
      this.publishFieldsTarget.classList.toggle("hidden", !showPublish)
      if (!showPublish) {
        const cb = this.publishFieldsTarget.querySelector("input[type=checkbox]")
        if (cb) cb.checked = false
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
