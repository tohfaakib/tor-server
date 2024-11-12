from flask import Flask, request, Response
import requests

app = Flask(__name__)

# Tor's local SOCKS5 proxy
PROXIES = {
    'http': 'socks5://127.0.0.1:12453',
    'https': 'socks5://127.0.0.1:12453'
}

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def proxy(path):
    # Construct the full URL to forward to
    url = request.url.replace(request.host_url, 'http://')  # Proxy all paths

    # Forward the request headers and method
    headers = {key: value for key, value in request.headers if key != 'Host'}
    method = request.method.lower()

    try:
        # Forward the request with appropriate method and data
        response = getattr(requests, method)(url, headers=headers, data=request.data, proxies=PROXIES)

        # Return the response content to the client
        return Response(response.content, status=response.status_code, headers=dict(response.headers))
    except requests.RequestException as e:
        return Response(str(e), status=500)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
