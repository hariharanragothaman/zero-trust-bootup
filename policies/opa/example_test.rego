package httpapi.authz

test_allow_admin if {
  allow with input as {"attributes": {"request": {"http": {
    "headers": {"user": "admin"},
    "method": "GET",
    "path": "/",
  }}}}
}

test_deny_guest if {
  not allow with input as {"attributes": {"request": {"http": {
    "headers": {"user": "guest"},
    "method": "GET",
    "path": "/",
  }}}}
}

test_deny_no_user_header if {
  not allow with input as {"attributes": {"request": {"http": {
    "headers": {},
    "method": "GET",
    "path": "/",
  }}}}
}

test_deny_empty_user if {
  not allow with input as {"attributes": {"request": {"http": {
    "headers": {"user": ""},
    "method": "GET",
    "path": "/",
  }}}}
}

test_allow_admin_any_method if {
  allow with input as {"attributes": {"request": {"http": {
    "headers": {"user": "admin"},
    "method": "POST",
    "path": "/data",
  }}}}
}
