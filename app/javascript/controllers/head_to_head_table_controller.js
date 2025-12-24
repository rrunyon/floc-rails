import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  hover(event) {
    const cell = event.target.closest("td,th")
    if (!cell || !this.element.contains(cell)) {
      return
    }

    const row = cell.dataset.row
    const col = cell.dataset.col
    if (!row && !col) {
      return
    }

    if (this.currentRow === row && this.currentCol === col) {
      return
    }

    this.clearHighlights()
    this.currentRow = row
    this.currentCol = col

    const highlighted = new Set()
    if (row) {
      this.element.querySelectorAll(`[data-row="${row}"]`).forEach((el) => highlighted.add(el))
    }
    if (col) {
      this.element.querySelectorAll(`[data-col="${col}"]`).forEach((el) => highlighted.add(el))
    }

    highlighted.forEach((el) => el.classList.add("is-selected"))
    cell.classList.add("is-selected-cell")
    this.highlighted = highlighted
    this.activeCell = cell
  }

  clear(event) {
    if (event && event.relatedTarget && this.element.contains(event.relatedTarget)) {
      return
    }

    this.clearHighlights()
    this.currentRow = null
    this.currentCol = null
  }

  clearHighlights() {
    if (!this.highlighted) {
      return
    }

    this.highlighted.forEach((el) => el.classList.remove("is-selected"))
    this.highlighted = null
    if (this.activeCell) {
      this.activeCell.classList.remove("is-selected-cell")
      this.activeCell = null
    }
  }
}
