import { Controller } from "@hotwired/stimulus"

const MONTHS = [
  "january","february","march","april","may","june",
  "july","august","september","october","november","december"
]

export default class extends Controller {
  static targets = ["date"]

  go(event) {
    event.preventDefault()
    const val = this.dateTarget.value
    if (!val) return
    const [year, month, day] = val.split("-").map(Number)
    window.location.href = `/date/${year}/${MONTHS[month - 1]}/${day}`
  }
}
