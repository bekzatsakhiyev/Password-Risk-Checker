# app.py
from flask import Flask, request, jsonify
import joblib
import re
from flask_cors import CORS

model = joblib.load('model.pkl')

def extract_features(password):
    length = len(password)
    has_upper = bool(re.search(r'[A-Z]', password))
    has_digit = bool(re.search(r'\d', password))
    has_special = bool(re.search(r'[^A-Za-z0-9]', password))
    return [[length, has_upper, has_digit, has_special]]

app = Flask(__name__)
CORS(app)
@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.json
    password = data['password']
    features = extract_features(password)
    risk = model.predict(features)[0]
    labels = ['LOW', 'MEDIUM', 'HIGH']
    return jsonify({'risk_level': labels[risk]})

if __name__ == '__main__':
    app.run(debug=True)
