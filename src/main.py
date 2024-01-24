from typing import Optional
# from mangum import Mangum

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "This is Home"}

@app.get("/test1")
def read_root():
    return {"Hello": "World Test1"}

@app.get("/test2")
def read_root():
    return {"Hello": "World Test2"}

# export port 8080
# handler = Mangum(app)