from flask import Flask, request, Response, jsonify
import requests
from stem import Signal
from stem.control import Controller

app = Flask(__name__)

# Health check endpoint
@app.route('/hello', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200

# Tor's local SOCKS5 proxy
PROXIES = {
    'http': 'socks5://127.0.0.1:12453',
    'https': 'socks5://127.0.0.1:12453'
}

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def proxy(path):
    url = request.url.replace(request.host_url, 'http://')  # Proxy all paths
    headers = {key: value for key, value in request.headers if key != 'Host'}
    method = request.method.lower()

    try:
        response = getattr(requests, method)(url, headers=headers, data=request.data, proxies=PROXIES)
        return Response(response.content, status=response.status_code, headers=dict(response.headers))
    except requests.RequestException as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
