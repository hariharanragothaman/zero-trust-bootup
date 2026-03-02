from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify({
        "message": f"Echo from {request.headers.get('user', 'anonymous')}",
        "headers": {
            "user": request.headers.get("user", ""),
            "host": request.headers.get("host", ""),
        },
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
