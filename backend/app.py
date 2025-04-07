## Código relacionado com o backend da applicação e API

from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2

app = Flask(__name__)
CORS(app, resources={"/*": {"origins": "http://54.204.92.62"}}) # ADD IP WITHOUT PORT

def get_db_connection():
    conn = psycopg2.connect(
        host='13.48.24.89', 
        database='ecommerce_db',
        user='ecommerce_user',
        password='password'
    )
    return conn

#testando a conexão
@app.route('/test_db', methods=['GET'])
def test_db():
    try:
        conn = get_db_connection() # Conectar ao banco de dados
        cur = conn.cursor()
        cur.execute('SELECT 1;') # Realiza uma consulta simples
        result = cur.fetchone() # Pega o resultado da consulta
        cur.close()
        conn.close()

        if result:
            return jsonify({"message": "Conexão bem-sucedida com o banco de dados!"}), 200
        else:
            return jsonify({"message": "Falha na conexão!"}), 500

    except Exception as e:
        return jsonify({"error": str(e)}), 500


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
