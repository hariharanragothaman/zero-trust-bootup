from flask import Flask, request
app = Flask(__name__)
@app.route("/")
def index():
    return f"Echo from {request.headers.get('user','anonymous')}"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)