from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Разрешаем запросы извне

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.json
    password = data['password']
    risk = "LOW"
    if len(password) < 6:
        risk = "HIGH"
    elif len(password) < 10:
        risk = "MEDIUM"
    return jsonify({'risk_level': risk})

if __name__ == '__main__':
    app.run(debug=True)
