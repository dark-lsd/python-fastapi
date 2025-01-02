from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/test_route")
def read_test_route():
    return {"Hello": "Test Route"}

@app.get("/route2")
def read_route():
    return "Hello world"

uvicorn.run(app, host="0.0.0.0", port=8080)
