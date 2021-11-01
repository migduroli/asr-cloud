import os

import uvicorn
from fastapi import FastAPI, Request

from utils import hello_world

app = FastAPI(title="Example API", docs_url="/")


@app.get("/hello")
def salute() -> dict:
    return {"message": hello_world.say_hello(os.environ.get("DEPLOYMENT_TAG", None))}


def main() -> None:
    uvicorn.run(
        "main:app",
        debug=False,
        log_level="debug",
        port=int(os.environ.get("PORT", 8080)),
        reload=True
    )


if __name__ == "__main__":
    main()
