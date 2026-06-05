import { Controller } from "@hotwired/stimulus"

function addMonthsSmart(date, months) {
  const y = date.getFullYear()
  const m = date.getMonth()
  const d = date.getDate()

  const targetMonth = m + months
  const tmp = new Date(y, targetMonth, 1, date.getHours(), date.getMinutes(), date.getSeconds())
  const lastDay = new Date(tmp.getFullYear(), tmp.getMonth() + 1, 0).getDate()
  const day = Math.min(d, lastDay)
  return new Date(tmp.getFullYear(), tmp.getMonth(), day, date.getHours(), date.getMinutes(), date.getSeconds())
}

export default class extends Controller {
  static targets = ["date", "operation", "amount", "unit", "example"]

  connect() {
    this.updateExample()
    // Observe input changes to update example in real-time
    if (this.dateTarget) this.dateTarget.addEventListener('input', () => this.updateExample())
    if (this.amountTarget) this.amountTarget.addEventListener('input', () => this.updateExample())
    if (this.unitTarget) this.unitTarget.addEventListener('change', () => this.updateExample())
    if (this.operationTarget) this.operationTarget.addEventListener('change', () => this.updateExample())
  }

  updateExample() {
    const date = this.parseDateInput()
    const amount = parseInt(this.amountTarget.value || "0", 10)
    const unit = this.unitTarget.value
    const op = this.operationTarget.value

    const result = this.compute(date, op, amount, unit)
    this.exampleTarget.textContent = result.toLocaleString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })
  }

  parseDateInput() {
    const val = this.dateTarget.value
    if (val) return new Date(val + 'T00:00:00')
    return new Date()
  }

  compute(base, op, amount, unit) {
    const factor = op === 'subtract' ? -1 : 1
    const n = factor * amount

    if (unit === 'days') {
      return new Date(base.getTime() + n * 24 * 3600 * 1000)
    }
    if (unit === 'weeks') {
      return new Date(base.getTime() + n * 7 * 24 * 3600 * 1000)
    }
    if (unit === 'months') {
      return addMonthsSmart(base, n)
    }
    if (unit === 'years') {
      return addMonthsSmart(base, n * 12)
    }
    return base
  }

  calculate() {
    const base = this.parseDateInput()
    const op = this.operationTarget.value
    const amount = parseInt(this.amountTarget.value || '0', 10)
    const unit = this.unitTarget.value

    const result = this.compute(base, op, amount, unit)

    const container = document.getElementById('date-calculator-result')
    container.innerHTML = `<div class="bg-white border rounded p-4"><p class="font-semibold">Result: ${result.toLocaleString(undefined, { month: 'long', day: 'numeric', year: 'numeric' })}</p></div>`
  }

  preset(event) {
    const val = parseInt(event.currentTarget.dataset.value, 10)
    this.dateTarget.value = new Date().toISOString().slice(0,10)
    this.operationTarget.value = 'add'
    this.unitTarget.value = 'days'
    this.amountTarget.value = val
    this.updateExample()
  }

  presetAgo(event) {
    const val = parseInt(event.currentTarget.dataset.value, 10)
    this.dateTarget.value = new Date().toISOString().slice(0,10)
    this.operationTarget.value = 'subtract'
    this.unitTarget.value = 'days'
    this.amountTarget.value = val
    this.updateExample()
  }

  // update when inputs change
  change() {
    this.updateExample()
  }
}
