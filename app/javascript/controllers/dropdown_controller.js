import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  toggle(event) {
    event.stopPropagation();
    this.element.classList.toggle("is-active");
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.element.classList.remove("is-active");
    }
  }

  closeOnItemClick(event) {
    if (event.target.closest(".dropdown-item")) {
      this.element.classList.remove("is-active");
    }
  }

  connect() {
    document.addEventListener("click", this.close.bind(this));
    this.element.addEventListener("click", this.closeOnItemClick.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.close.bind(this));
    this.element.removeEventListener("click", this.closeOnItemClick.bind(this));
  }
}
