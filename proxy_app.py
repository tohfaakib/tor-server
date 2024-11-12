from flask import Flask, request, Response, jsonify
import requests
from stem import Signal
from stem.control import Controller

app = Flask(__name__)

# Health check endpoint
@app.route('/hello', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200

# Privoxy HTTP proxy (which forwards requests to Tor's SOCKS5 proxy)
PROXIES = {
    'http': 'http://127.0.0.1:8118',
    'https': 'http://127.0.0.1:8118'
}

# Endpoint to renew Tor connection
@app.route('/renew', methods=['POST'])
def renew_connection():
    try:
        with Controller.from_port(address="127.0.0.1", port=12454) as controller:
            controller.authenticate(password="TorPass34")
            controller.signal(Signal.NEWNYM)
            return jsonify({"status": "Tor connection renewed"}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Proxy endpoint to forward requests through Tor via Privoxy
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def proxy(path):
    url = request.url.replace(request.host_url, 'http://')  # Proxy all paths
    headers = {key: value for key, value in request.headers if key != 'Host'}
    method = request.method.lower()

    try:
        # Forward the request with appropriate method, headers, and data through Privoxy
        response = getattr(requests, method)(url, headers=headers, data=request.data, proxies=PROXIES)
        return Response(response.content, status=response.status_code, headers=dict(response.headers))
    except requests.RequestException as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
