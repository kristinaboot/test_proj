from flask import Flask, request, jsonify

app = Flask(__name__)

tasks = [] #хранение
next_id = 1


@app.route("/tasks/", methods=["GET", "POST", "DELETE"])
def tasks_api():
    global next_id

    if request.method == "GET":
        return jsonify(tasks)

    if request.method == "POST":
        data = request.json

        if not data or "title" not in data: #тайтл обязательный
            return jsonify({"error": "title is required"}), 400

        task = {
            "id": next_id,
            "title": data["title"],
            "completed": False #каждый новый тайтл по умолч невыполненный
        }

        tasks.append(task)
        next_id += 1 #id уникальный

        return jsonify(task), 201

    if request.method == "DELETE":
        data = request.json

        if not data or "id" not in data:
            return jsonify({"error": "id is required"}), 400

        for task in tasks:
            if task["id"] == data["id"]:
                tasks.remove(task)
                return jsonify({"message": "deleted"})

        return jsonify({"error": "task not found"}), 404


app.run(debug=True)