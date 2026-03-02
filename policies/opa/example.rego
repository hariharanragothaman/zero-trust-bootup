package httpapi.authz

default allow = false

allow if {
  input.attributes.request.http.headers.user == "admin"
}
