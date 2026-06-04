import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const hash = window.location.hash.replace("#", "") || "my-countdowns"
    this.show(hash)
  }

  show(panelId) {
    this.panelTargets.forEach(p => p.classList.toggle("hidden", p.id !== panelId))
    this.tabTargets.forEach(t => {
      const active = t.dataset.tab === panelId
      t.classList.toggle("border-blue-600", active)
      t.classList.toggle("text-blue-600", active)
      t.classList.toggle("border-transparent", !active)
      t.classList.toggle("text-slate-500", !active)
    })
  }

  tabTargetConnected(tab) {
    tab.addEventListener("click", e => {
      e.preventDefault()
      history.replaceState(null, "", "#" + tab.dataset.tab)
      this.show(tab.dataset.tab)
    })
  }
}
