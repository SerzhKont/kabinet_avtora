// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "trix"
import "@rails/actiontext"

document.addEventListener('DOMContentLoaded', () => {
  // Получаем все элементы с классом navbar-burger
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Проверяем, есть ли бургеры
  if ($navbarBurgers.length > 0) {
    // Добавляем обработчик клика для каждого бургера
    $navbarBurgers.forEach(el => {
      el.addEventListener('click', () => {
        // Получаем цель из data-target
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        // Переключаем класс is-active для бургера и меню
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');
      });
    });
  }
});

document.addEventListener('DOMContentLoaded', () => {
    // Получаем все элементы с классом dropdown
    const dropdowns = document.querySelectorAll('.dropdown');

    dropdowns.forEach(dropdown => {
      dropdown.addEventListener('click', function(event) {
        event.stopPropagation();
        this.classList.toggle('is-active');
      });
    });

    // Закрываем дропдаун при клике вне его
    document.addEventListener('click', () => {
      dropdowns.forEach(dropdown => {
        dropdown.classList.remove('is-active');
      });
    });
  });
