from flask import Flask
app = Flask(__name__)

@app.get("/")
def home():
    return "Hello, Kubernetes!", 200

if __name__ == "__main__":
    # Bind to 0.0.0.0 for container networking; port via env or default 5000
    import os
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port)
