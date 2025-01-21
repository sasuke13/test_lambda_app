from fastapi import FastAPI
from mangum import Mangum
import logging
from pydantic import BaseModel

class Item(BaseModel):
    q: str | None = None

app = FastAPI()
handler = Mangum(app)

logger = logging.getLogger()
logger.setLevel(logging.INFO)

@app.get("/")
def read_root():
    logger.info("Processing request to root endpoint")
    return {"message": "Hello, World and Lambda!"}

@app.get("/items")
def read_item():
    return {
        "items": ["item1", "item2", "item3"],
        "name": "John Doe",
        "description": "This is a test description"
    }

@app.post("/items/{item_id}")
def create_item(item_id: int, item: Item):
    return {"item_id": item_id, "q": item.q}
