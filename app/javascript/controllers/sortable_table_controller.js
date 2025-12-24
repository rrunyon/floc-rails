import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    defaultIndex: Number,
    defaultDirection: String
  }

  connect() {
    if (Number.isInteger(this.defaultIndexValue)) {
      const direction = this.defaultDirectionValue || "asc"
      this.sortBy(this.defaultIndexValue, direction, this.typeForIndex(this.defaultIndexValue))
    }
  }

  sort(event) {
    const header = event.currentTarget
    const index = parseInt(header.dataset.sortIndex, 10)
    const type = header.dataset.sortType || "text"
    const current = header.dataset.sortDirection || "desc"
    const direction = current === "asc" ? "desc" : "asc"

    this.element.querySelectorAll("th[data-sort-index]").forEach((th) => {
      th.dataset.sortDirection = ""
    })
    header.dataset.sortDirection = direction

    this.sortBy(index, direction, type)
  }

  sortBy(index, direction, type) {
    const tbody = this.element.tBodies[0]
    const rows = Array.from(tbody.rows)

    rows.sort((a, b) => {
      const left = this.cellValue(a, index, type)
      const right = this.cellValue(b, index, type)
      if (left < right) return direction === "asc" ? -1 : 1
      if (left > right) return direction === "asc" ? 1 : -1
      return 0
    })

    rows.forEach((row) => tbody.appendChild(row))
  }

  cellValue(row, index, type) {
    const cell = row.cells[index]
    if (!cell) return ""
    const dataNode = cell.querySelector("[data-sort-value]")
    const raw = dataNode ? dataNode.dataset.sortValue : cell.dataset.sortValue || cell.textContent
    return type === "number" ? parseFloat(raw) || 0 : raw.trim().toLowerCase()
  }

  typeForIndex(index) {
    const header = this.element.querySelector(`th[data-sort-index="${index}"]`)
    return header ? header.dataset.sortType || "text" : "text"
  }
}
