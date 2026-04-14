# AI Development Guidelines for MedApp

To ensure high-quality code and avoid common Flutter/Dart pitfalls, the following rules MUST be followed:

## 1. Quality Assurance
- **Always run linting**: Before finishing a task, run `/opt/homebrew/bin/flutter analyze`.
- **Zero Errors Policy**: Never submit code that has compilation errors or analyzer errors. Warnings should be addressed if they relate to the current changes.

## 2. Flutter Best Practices
- **Constant Expressions**: Be extremely careful with `const` constructors. Method calls like `Theme.of(context)` or `MediaQuery.of(context)` are NOT constant and cannot be used where a `const` value is expected.
- **Deprecated Members**:
  - Replace `color.withOpacity(0.5)` with `color.withValues(alpha: 0.5)`.
  - Replace `DropdownButtonFormField(value: ...)` with `initialValue: ...` if applicable.
- **BuildContext**:
  - In `StatelessWidget` helper methods, always pass `BuildContext context` as the first argument.
  - In `StatefulWidget` methods, use `context` (if available in scope) or `widget.context` is not a thing, use `mounted` check before using `context` after async gaps.

## 3. UI/UX
- Use the established design system (premium look, specific color palettes).
- Maintain German localization for all UI strings.
