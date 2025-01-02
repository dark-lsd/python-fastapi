from flask import Flask

app = Flask(__name__)

@app.get("/")
def index():
    return "Hello world"

@app.get("/test")
def test():
    return "Test"


app.run(host="0.0.0.0", port=8000)
