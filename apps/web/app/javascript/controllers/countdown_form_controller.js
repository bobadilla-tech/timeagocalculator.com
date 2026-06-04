import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "passwordFields", "isPublicField", "visibilityRadio", "publishFields",
    "guestOpenHint", "guestProtectedHint", "guestPrivateError"
  ]

  connect() {
    this.updateVisibility()
  }

  setVisibility() {
    this.updateVisibility()
  }

  preventIfGuestPrivate(event) {
    const isGuest = this.element.dataset.countdownFormGuest === "true"
    if (isGuest && this.visibilityValue() === "private") {
      event.preventDefault()
      if (this.hasGuestPrivateErrorTarget) {
        this.guestPrivateErrorTarget.scrollIntoView({ behavior: "smooth", block: "center" })
      }
    }
  }

  updateVisibility() {
    const selected  = this.visibilityValue()
    const isGuest   = this.element.dataset.countdownFormGuest === "true"

    // Password fields
    if (this.hasPasswordFieldsTarget) {
      this.passwordFieldsTarget.classList.toggle("hidden", selected !== "protected")
      if (selected !== "protected") {
        this.passwordFieldsTarget.querySelectorAll("input[type=password]").forEach(el => el.value = "")
      }
    }

    // Publish / feature toggle
    if (this.hasPublishFieldsTarget) {
      this.publishFieldsTarget.classList.toggle("hidden", selected === "private")
      if (selected === "private") {
        const cb = this.publishFieldsTarget.querySelector("input[type=checkbox]")
        if (cb) cb.checked = false
      }
    }

    // is_public hidden field
    if (this.hasIsPublicFieldTarget) {
      this.isPublicFieldTarget.value = selected === "private" ? "0" : "1"
    }

    // Guest hints
    if (isGuest) {
      if (this.hasGuestOpenHintTarget) {
        this.guestOpenHintTarget.classList.toggle("hidden", selected !== "open")
      }
      if (this.hasGuestProtectedHintTarget) {
        this.guestProtectedHintTarget.classList.toggle("hidden", selected !== "protected")
      }
      if (this.hasGuestPrivateErrorTarget) {
        this.guestPrivateErrorTarget.classList.toggle("hidden", selected !== "private")
      }
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
