// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

// Обработчик для navbar-бургеров и дропдаунов
document.addEventListener('turbo:load', () => {
  // Navbar-бургеры
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  if ($navbarBurgers.length > 0) {
    $navbarBurgers.forEach(el => {
      el.addEventListener('click', () => {
        const target = el.dataset.target;
        const $target = document.getElementById(target);
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');
      });
    });
  }

  // Дропдауны
  const dropdowns = document.querySelectorAll('.dropdown');
  dropdowns.forEach(dropdown => {
    dropdown.addEventListener('click', function(event) {
      event.stopPropagation();
      this.classList.toggle('is-active');
    });
  });

  // Закрытие дропдаунов при клике вне
  document.addEventListener('click', () => {
    dropdowns.forEach(dropdown => {
      dropdown.classList.remove('is-active');
    });
  });

  // Обработчик для модалок
  const modals = document.querySelectorAll('.modal');
  const modalTriggers = document.querySelectorAll('.modal-trigger');

  // Открытие модалки
  modalTriggers.forEach(trigger => {
    trigger.addEventListener('click', (e) => {
      e.preventDefault();
      const modalId = trigger.getAttribute('data-target');
      const modal = document.getElementById(modalId);
      if (modal) {
        modal.classList.add('is-active');
      }
    });
  });

  // Закрытие модалки при клике на фон или кнопку закрытия
  modals.forEach(modal => {
    const closeButtons = modal.querySelectorAll('.delete, .modal-background, .button[onclick]');
    closeButtons.forEach(button => {
      button.addEventListener('click', () => {
        modal.classList.remove('is-active');
      });
    });
  });

  // Закрытие модалки после успешного удаления (для AJAX)
  document.addEventListener('ajax:complete', (event) => {
    const [response, status, xhr] = event.detail;
    if (status === 'success' && xhr.responseURL.includes('/authors/')) {
      modals.forEach(modal => {
        modal.classList.remove('is-active');
      });
    }
  });

  const selectAllCheckbox = document.getElementById('select-all-documents');
  const documentCheckboxes = document.querySelectorAll('.document-checkbox');
  const signButton = document.getElementById('sign-selected-documents');
  const selectedCount = document.getElementById('selected-count');

  // Активация/деактивация кнопки отправки
  function updateSignButton() {
    const checkedCount = document.querySelectorAll('.document-checkbox:checked').length;
    selectedCount.textContent = checkedCount;
    signButton.disabled = checkedCount === 0;
  }

  // Обработчик для "Выбрать все"
  selectAllCheckbox.addEventListener('change', function() {
    documentCheckboxes.forEach(cb => {
      cb.checked = this.checked;
    });
    updateSignButton();
  });

  // Обработчик для отдельных чекбоксов
  documentCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
      if (!this.checked) {
        selectAllCheckbox.checked = false;
      }
      updateSignButton();
    });
  });

  // Обработчик кнопки отправки
signButton.addEventListener('click', function(e) {
    e.preventDefault();
    const selectedDocs = Array.from(document.querySelectorAll('.document-checkbox:checked')).map(cb => ({
      id: cb.value,
      title: cb.dataset.title
    }));

    if (selectedDocs.length > 0) {
      fetch('/documents/send_signing_link', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ document_ids: selectedDocs.map(doc => doc.id) })
      })
      .then(response => response.json())
      .then(data => {
        if (data.deeplink) {
          alert(`Ссылка отправлена автору: ${data.deeplink}`);
          // Здесь можно отправить deeplink по email или через уведомление
        } else {
          alert('Ошибка при создании deeplink: ' + (data.error || 'Неизвестная ошибка'));
        }
      })
      .catch(error => {
        console.error('Ошибка:', error);
        alert('Произошла ошибка при отправке запроса.');
      });
    }
  });
});
