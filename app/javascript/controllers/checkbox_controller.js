import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "signButton", "selectedCount"];

  connect() {
    this.updateSignButton();
  }

  toggleAll() {
    this.checkboxTargets.forEach((cb) => {
      cb.checked = this.selectAllTarget.checked;
    });
    this.updateSignButton();
  }

  toggleCheckbox() {
    if (!this.checkboxTargets.every((cb) => cb.checked)) {
      this.selectAllTarget.checked = false;
    }
    this.updateSignButton();
  }

  updateSignButton() {
    const checkedCount = this.checkboxTargets.filter((cb) => cb.checked).length;
    this.selectedCountTarget.textContent = checkedCount;
    this.signButtonTarget.disabled = checkedCount === 0;
  }

  sendSignRequest(event) {
    event.preventDefault();
    const selectedDocs = this.checkboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => ({
        id: cb.value,
        title: cb.dataset.title,
      }));

    if (selectedDocs.length > 0) {
      fetch("/documents/send_signing_link", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({
          document_ids: selectedDocs.map((doc) => doc.id),
        }),
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.deeplink) {
            alert(`Ссылка отправлена автору: ${data.deeplink}`);
          } else {
            alert(
              "Ошибка при создании deeplink: " +
                (data.error || "Неизвестная ошибка"),
            );
          }
        })
        .catch((error) => {
          console.error("Ошибка:", error);
          alert("Произошла ошибка при отправке запроса.");
        });
    }
  }
}
