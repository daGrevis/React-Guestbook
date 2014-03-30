import shelve

from flask import Flask, request, render_template, jsonify


app = Flask(__name__)
app.debug = True


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/comments/", methods=["GET", "POST"])
def comments():
    shelve_db = shelve.open("shelve.db")
    comments = shelve_db.get("comments", [])
    if request.method == "POST":
        comments.append({
            "name": request.form["name"],
            "email": request.form["email"],
            "content": request.form["content"],
        })
        shelve_db["comments"] = comments
    shelve_db.close()
    return jsonify(comments=comments)


if __name__ == "__main__":
    app.run()
