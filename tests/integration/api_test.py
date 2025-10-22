import requests
import os

API_URL = os.environ.get('API_URL', 'https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/hello')

def test_hello_endpoint():
    response = requests.get(API_URL)
    assert response.status_code == 200
    data = response.json()
    assert 'message' in data
    assert data['message'] == 'Hello from API Gateway!'
    print("✓ Test passed!")

if __name__ == '__main__':
    test_hello_endpoint()
