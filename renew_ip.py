from flask import Flask, jsonify
from stem import Signal
from stem.control import Controller

app = Flask(__name__)

# Health check endpoint
@app.route('/hello', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200

@app.route('/renew', methods=['POST'])
def renew_connection():
    try:
        with Controller.from_port(address="127.0.0.1", port=12454) as controller:
            controller.authenticate(password="TorPass34")
            controller.signal(Signal.NEWNYM)
            return jsonify({"status": "Tor connection renewed"}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
