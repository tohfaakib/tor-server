from flask import Flask, request, Response, jsonify
import requests
from stem import Signal
from stem.control import Controller

app = Flask(__name__)

# Configure the Tor SOCKS5 proxy
PROXIES = {
    'http': 'socks5://127.0.0.1:12453',
    'https': 'socks5://127.0.0.1:12453'
}


# Health check endpoint
@app.route('/hello', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200


# Endpoint to renew Tor connection
@app.route('/renew', methods=['GET', 'POST'])
def renew_connection():
    try:
        with Controller.from_port(address="127.0.0.1", port=12454) as controller:
            controller.authenticate(password="TorPass34")
            controller.signal(Signal.NEWNYM)
            return jsonify({"status": "Tor connection renewed"}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Flexible proxy endpoint
@app.route('/request', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'])
def proxy_request():
    # Extract the target URL from the query parameter
    target_url = request.args.get('url')
    if not target_url:
        return jsonify({'error': "Missing 'url' parameter"}), 400

    # Prepare the request headers, cookies, and data
    headers = dict(request.headers)
    cookies = request.cookies
    data = request.get_data()  # Handles both JSON and form data transparently
    json_data = request.get_json(silent=True)  # Parse JSON data if available

    try:
        # Forward the request with the same method, headers, data, and cookies
        response = requests.request(
            method=request.method,
            url=target_url,
            headers=headers,
            cookies=cookies,
            data=data if not json_data else None,
            json=json_data,
            proxies=PROXIES,
            allow_redirects=False
        )

        # Return the response to the client
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in response.raw.headers.items()
                   if name.lower() not in excluded_headers]
        response_content = response.content
        return Response(response_content, response.status_code, headers)
    except requests.RequestException as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
