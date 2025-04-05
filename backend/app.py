## Código relacionado com o backend da applicação e API

from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={"/*": {"origins": "http://54.234.82.136"}}) # ADD IP WITHOUT PORT

# Lista de produtos (simulando um banco de dados)
products = [
    {"id": 1, "name": "Produto A", "price": 19.99},
    {"id": 2, "name": "Produto B", "price": 29.99},
    {"id": 3, "name": "Produto C", "price": 39.99},
]

# Carrinho de compras (armazenado na memória do servidor)
cart = []

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(products), 200

@app.route('/addToCart', methods=['POST'])
def addToCart():
    return jsonify({"message": "Added to cart!"}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
