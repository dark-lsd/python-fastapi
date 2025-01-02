from flask import Flask
import uvicorn

app = Flask(__name__)

@app.get("/")
def index():
    return "Hello world"

@app.get("/test")
def test():
    return "Test"

uvicorn.run(app, host="0.0.0.0", port=8080)
