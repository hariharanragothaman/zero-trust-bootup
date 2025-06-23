package httpapi.authz

default allow = false

allow if {
  input.attributes.request.http.method == "GET"
  input.attributes.request.http.headers.user == "admin"
  input.attributes.request.http.path == "/users"
}
