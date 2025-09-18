import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropdownMenu"];

  toggle(event) {
    event.stopPropagation();
    // Проверяем ширину экрана
    if (window.innerWidth <= 768) {
      this.element.classList.toggle("is-active");
    }
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
    // Убедимся, что is-active удалён на больших экранах при загрузке
    if (window.innerWidth > 768) {
      this.element.classList.remove("is-active");
    }
  }

  disconnect() {
    document.removeEventListener("click", this.close.bind(this));
    this.element.removeEventListener("click", this.closeOnItemClick.bind(this));
  }
}
