# Agent Coding Guidelines for kabinet_avtora

This document outlines the technical conventions and commands for automated agents operating within this Ruby on Rails project.

## 1. Commands

| Type | Command | Notes |
| :--- | :--- | :--- |
| **Lint** | `bin/rubocop` | Run to check all Ruby code style. |
| **Test All** | `bin/rails test` | Runs all Minitest unit and integration tests. |
| **Test File** | `bin/rails test <path/to/file_test.rb>` | Example: `bin/rails test test/models/document_test.rb` |
| **Test Case** | `bin/rails test <path> -n /<test_name>/` | Run a single test method. |
| **Security** | `bin/brakeman` | Run to check for security vulnerabilities. |
| **Build** | `bin/rails assets:precompile` | Compile assets (usually run during deployment). |

## 2. Code Style & Conventions

*   **Language:** Ruby (Rails 8.0.2) and JavaScript (Stimulus/Importmap).
*   **Ruby Style:** Adhere strictly to the rules defined in `.rubocop.yml`, which inherits from `rubocop-rails-omakase`.
*   **Naming:** Use standard Ruby/Rails conventions (snake_case for methods/variables, CamelCase for classes/modules).
*   **Imports:** Use `require` for Ruby dependencies. For JavaScript, use ESM imports via `importmap-rails`.
*   **Error Handling:** Prefer standard Rails error handling patterns (e.g., `rescue` blocks, `flash` messages, `ActiveRecord` validation errors).
*   **Frontend:** Use Hotwire (Turbo and Stimulus) for frontend interactivity. Avoid adding new, large JavaScript libraries.
