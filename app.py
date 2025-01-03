from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def index():
    return "Hello world"

@app.get("/test")
def test():
    return "Test"

@app.get("/test/{hii}")
def test1(hii: str):
    return {"param": hii}

@app.get("/test2/")
def test2():
    return {"test2": "pass"}

# app.run(host="0.0.0.0", port=8000)
