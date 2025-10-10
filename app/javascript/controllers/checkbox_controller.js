import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox", "selectedCount", "selectAll", "deleteButton"];

  connect() {
    // Инициализируем счетчик при загрузке
    this.updateCounter();
  }

  // Выделить/снять выделение всех
  toggleAll(event) {
    const checked = event.target.checked;
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked;
    });
    this.updateCounter();
  }

  // Обновить счетчик при изменении любого чекбокса
  updateCounter() {
    const selectedCount = this.checkboxTargets.filter(
      (checkbox) => checkbox.checked,
    ).length;

    // Обновляем текст счетчика
    this.selectedCountTarget.textContent = selectedCount;

    // Обновляем кнопку удаления
    this.updateDeleteButton(selectedCount);

    // Обновляем состояние "Выделить все"
    this.updateSelectAllState(selectedCount);
  }

  preventIfDisabled(event) {
    if (this.deleteButtonTarget.classList.contains("disabled")) {
      event.preventDefault();
      event.stopPropagation();
    } else {
      // Обновляем ссылку с актуальным количеством
      const selectedCount = this.checkboxTargets.filter(
        (checkbox) => checkbox.checked,
      ).length;
      const url = new URL(this.deleteButtonTarget.href);
      url.searchParams.set("selected_count", selectedCount);
      this.deleteButtonTarget.href = url.toString();
    }
  }

  updateDeleteButton(selectedCount) {
    if (selectedCount > 0) {
      // Активируем кнопку
      this.deleteButtonTarget.classList.remove("disabled");
      this.deleteButtonTarget.title = "Видалити обрані";
    } else {
      // Деактивируем кнопку
      this.deleteButtonTarget.classList.add("disabled");
      this.deleteButtonTarget.title =
        "Виберіть хоча б один документ для видалення";
    }
  }

  updateSelectAllState(selectedCount) {
    if (selectedCount === 0) {
      this.selectAllTarget.checked = false;
      this.selectAllTarget.indeterminate = false;
    } else if (selectedCount === this.checkboxTargets.length) {
      this.selectAllTarget.checked = true;
      this.selectAllTarget.indeterminate = false;
    } else {
      this.selectAllTarget.checked = false;
      this.selectAllTarget.indeterminate = true;
    }
  }
}
