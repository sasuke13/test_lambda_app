from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()
handler = Mangum(app)

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

@app.get("/items")
def read_item():
    return {
        "items": ["item1", "item2", "item3"],
        "name": "John",
        "description": "This is a test description"
    }

@app.post("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
