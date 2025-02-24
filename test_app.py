import unittest
from app import app

class FlaskAppTestCase(unittest.TestCase):
    
    # Set up the test client
    def setUp(self):
        self.client = app.test_client()
        self.client.testing = True

    # Test the '/' route
    def test_hello(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data.decode('utf-8'), 'Code is Working')

if __name__ == '__main__':
    unittest.main()
