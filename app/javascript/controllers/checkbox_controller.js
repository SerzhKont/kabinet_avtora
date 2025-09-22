import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "checkbox",
    "selectAll",
    "signButton",
    "selectedCount",
    "deleteButton",
    "deleteModal",
    "deleteCount",
  ];

  connect() {
    this.updateButtons();
  }

  toggleAll() {
    this.checkboxTargets.forEach((cb) => {
      cb.checked = this.selectAllTarget.checked;
    });
    this.updateButtons();
  }

  toggleCheckbox() {
    const allChecked = this.checkboxTargets.every((cb) => cb.checked);
    const someChecked = this.checkboxTargets.some((cb) => cb.checked);

    this.selectAllTarget.checked = allChecked;
    this.selectAllTarget.indeterminate = someChecked && !allChecked;

    this.updateButtons();
  }

  updateButtons() {
    const checkedCount = this.checkboxTargets.filter((cb) => cb.checked).length;
    this.selectedCountTarget.textContent = checkedCount;
    this.deleteCountTarget.textContent = checkedCount;
    this.signButtonTarget.disabled = checkedCount === 0;
    this.deleteButtonTarget.disabled = checkedCount === 0;
  }

  showDeleteModal() {
    this.deleteModalTarget.classList.add("is-active");
  }

  confirmBulkDelete(event) {
    event.preventDefault();
    const form = this.element.querySelector("#bulk-delete-form");
    const selectedIds = this.checkboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value);

    if (selectedIds.length === 0) {
      alert("Оберіть хоча б один документ для видалення.");
      return;
    }

    // Добавляем скрытые поля с ID документов в форму
    selectedIds.forEach((id) => {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "document_ids[]";
      input.value = id;
      form.appendChild(input);
    });

    this.closeModal(); // Закрываем модальное окно
    form.submit();
  }

  closeModal() {
    this.deleteModalTarget.classList.remove("is-active");
  }

  getSelectedIds() {
    return this.checkboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value);
  }
  resetCheckboxes() {
    this.checkboxTargets.forEach((cb) => {
      cb.checked = false;
    });
    this.selectAllTarget.checked = false;
    this.selectAllTarget.indeterminate = false;
    this.updateButtons();
  }
}
