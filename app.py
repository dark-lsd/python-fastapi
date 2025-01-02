from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def index():
    return "Hello world"

@app.get("/test")
def test():
    return "Test"

uvicorn.run(app, host="0.0.0.0", port=8080)
