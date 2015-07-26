curl -H "Content-Type: application/json" -X POST -d '{
  "id": "juan",
  "pass": "supersecret",
  "role": "author"
}' http://localhost:3000/postgrest/users
