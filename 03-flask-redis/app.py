import os

from flask import Flask, request, jsonify
from redis import Redis


app = Flask(__name__)
redis_ip = os.environ["REDIS_IP_GCP"]

redis_server = Redis(
    host=redis_ip,
    port=6379,
    db=0,
    socket_timeout=5,
    charset="utf-8",
    decode_responses=True
)


@app.route("/", methods=["POST", "GET"])
def index():

    if request.method == "POST":
        name = request.json["name"]
        redis_server.rpush("students", {"name": name})
        return jsonify({"name": name})

    if request.method == "GET":
        return jsonify(redis_server.lrange("students", 0, -1))


@app.route("/reset", methods=["POST", "GET"])
def reset():
    redis_server.flushdb()
    return index()


def main_local_dev():
    app.run(host="0.0.0.0", port=5000, debug=False)


if __name__ == "__main__":
    main_local_dev()
