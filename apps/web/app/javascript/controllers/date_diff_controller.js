import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["from", "to"]

  fromChanged() {
    if (this.hasToTarget && this.hasFromTarget) {
      if (this.toTarget.value && this.toTarget.value < this.fromTarget.value) {
        this.toTarget.value = this.fromTarget.value
      }
    }
  }

  toChanged() {
    if (this.hasFromTarget && this.hasToTarget) {
      if (this.fromTarget.value && this.fromTarget.value > this.toTarget.value) {
        this.fromTarget.value = this.toTarget.value
      }
    }
  }
}
