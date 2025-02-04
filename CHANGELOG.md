

## [2.0.2](https://github.com/rownd/devise-rownd/compare/2.0.0...2.0.2) (2025-02-04)


### Bug Fixes

* **controller:** adds missing variable ([#6](https://github.com/rownd/devise-rownd/issues/6)) ([7838a15](https://github.com/rownd/devise-rownd/commit/7838a1585a1089b812be15d7e4c822d851a75ac1))

# [2.0.0](https://github.com/rownd/devise-rownd/compare/v1.1.0...2.0.0) (2024-06-17)


### Bug Fixes

* **docs:** typo in README ([c31b3c8](https://github.com/rownd/devise-rownd/commit/c31b3c8c35290a2b115fff60a875436b214e048b))


### Features

* change session storage model; chore: improve logging ([57dd566](https://github.com/rownd/devise-rownd/commit/57dd56689f6b4f087521e241a1a19ab7c17f4414))
* fetch entire user profile and set auth_level ([313dfb5](https://github.com/rownd/devise-rownd/commit/313dfb5300bbb846030600709830353c8662af50))

# 1.1.0 (June 3, 2022)

## Enhancements

  - Add `verified?` instance method to the user model

# 1.0.3 (May 13, 2022)

## Bug fixes:

  - Fix issue of caching bad API responses

## Enhancements:

  - Use the Warden `fail!` method for all authentication failures
  - Call Warden `authenticate!` from within the Auth Controller's authenticate action
  - Add the Devise::Rownd::Caching library