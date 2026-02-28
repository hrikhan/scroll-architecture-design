# Login Module Notes

This folder contains documentation for the login flow.

## Source files used by login
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/auth/viewmodels/auth_viewmodel.dart`
- `lib/features/auth/data/auth_remote_datasource.dart`
- `lib/features/auth/data/auth_repository_impl.dart`

## Login flow
1. User enters username and password in `login_screen.dart`.
2. UI calls `authViewModel.login(username, password)`.
3. ViewModel validates and delegates auth request to repository.
4. On success, user session is persisted and `AuthGate` navigates to products.
5. On failure, login screen shows error feedback.

## Test credential (FakeStore)
- `username`: `mor_2314`
- `password`: `83r5^_`
