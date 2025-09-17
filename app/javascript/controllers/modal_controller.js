import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  open(event) {
    event.preventDefault();
    const modalId = event.currentTarget.dataset.modalId;
    const modal = document.getElementById(modalId);
    if (modal) {
      modal.classList.add("is-active");
    }
    const dropdown = this.element.closest(".dropdown");
    if (dropdown) {
      dropdown.classList.remove("is-active");
    }
  }

  close(event) {
    event.preventDefault();
    const modal = this.element.closest(".modal");
    if (modal) {
      modal.classList.remove("is-active");
    }
  }
}
