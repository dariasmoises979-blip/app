from flask import Flask, render_template
import socket
import platform
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def index():
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    os_version = platform.platform()
    python_version = platform.python_version()
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return render_template("index.html", 
                           hostname=hostname,
                           ip_address=ip_address,
                           os_version=os_version,
                           python_version=python_version,
                           current_time=current_time)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

