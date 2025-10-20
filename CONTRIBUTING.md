# Contributing to Health Tracker Reports

First off, thank you for considering contributing! Your help is greatly appreciated. This document provides guidelines for contributing to the project.

## Core Principles

To maintain the quality and consistency of the codebase, we adhere to a few core principles. All contributions must follow these.

1.  **Test-Driven Development (TDD):** No production code should be written without a corresponding test that fails first. Write your tests, watch them fail, then write the code to make them pass.
2.  **Clean Architecture:** The project strictly follows Clean Architecture principles. Ensure your changes respect the separation of layers (Domain, Data, Presentation).
3.  **Conventional Commits:** Commit messages must follow the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/). This helps in automating changelogs and understanding the history of the project.

## Contribution Workflow

1.  **Fork the Repository:** Start by forking the main repository.
2.  **Clone Your Fork:** Clone your forked repository to your local machine.
3.  **Install Dependencies:** Run `flutter pub get` to install all the required dependencies.
4.  **Run Code Generation:** The project uses code generation for dependency injection. Run the following command before you start working and any time you add new injectable classes:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
5.  **Create a Branch:** Create a new branch for your feature or bugfix from the `main` branch.
    ```bash
    git checkout -b feat/my-new-feature
    ```
6.  **Write Tests:** Before writing any implementation, write the necessary unit or widget tests that cover your changes.
7.  **Write Code:** Write the implementation code to make your tests pass.
8.  **Ensure All Checks Pass:** Before submitting, ensure your code is formatted and passes all analysis checks:
    ```bash
    # Format your code
    dart format .

    # Run the analyzer
    flutter analyze

    # Run all tests
    flutter test
    ```
9.  **Commit Your Changes:** Commit your changes using a conventional commit message.
    ```bash
    git commit -m "feat: Implement the new feature"
    ```
10. **Push and Create a Pull Request:** Push your branch to your fork and open a pull request against the main repository's `main` branch.

## Code Style

Please follow the existing code style. The project uses the standard `flutter_lints` package to enforce a consistent style. Running `dart format .` will ensure your code meets the project's formatting requirements.
