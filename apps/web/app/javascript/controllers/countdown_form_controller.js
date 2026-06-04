import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passwordFields", "isPublicCheckbox"]

  connect() {
    this.togglePassword()
  }

  togglePassword() {
    if (!this.hasIsPublicCheckboxTarget || !this.hasPasswordFieldsTarget) return
    const isPublic = this.isPublicCheckboxTarget.checked
    this.passwordFieldsTarget.hidden = isPublic

    // Clear password fields when switching back to public to avoid validation errors
    if (isPublic) {
      this.passwordFieldsTarget.querySelectorAll("input[type=password]").forEach(el => {
        el.value = ""
      })
    }
  }
}
