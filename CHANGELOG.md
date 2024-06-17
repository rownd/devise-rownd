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