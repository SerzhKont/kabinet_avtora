import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];

  close(event) {
    event.preventDefault();
    this.hideModal();
  }

  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("is-active");

      // Очищаем только модалку (для отмены), не трогаем таблицу
      const modalFrame = this.modalTarget.closest(
        "turbo-frame[data-id='modal']",
      );
      if (modalFrame) {
        modalFrame.innerHTML = "";
      }
    }
  }
}
