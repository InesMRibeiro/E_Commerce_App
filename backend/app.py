## Código relacionado com o backend da applicação e API

from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS  # type: ignore
from config import Config

db = SQLAlchemy() 

app = Flask(__name__)
CORS(app, resources={"/*": {"origins": "http://54.204.92.62"}}) # Frontend IP without port
app.config.from_object('config.Config')
db.init_app(app) 

# Importe os modelos aqui APÓS a inicialização do db
from .models import Product, Cart

with app.app_context():
    db.create_all()


@app.route('/products', methods=['GET'])
def get_products():
    products = Product.query.all()
    product_list = [{"id": p.id, "name": p.name, "price": p.price} for p in products]
    return jsonify(product_list), 200

@app.route('/addToCart', methods=['POST'])
def addToCart():
    data = request.get_json()
    product_id = data.get('product_id')

    product = Product.query.get(product_id)
    if product:
        # Verificar se o item já está no carrinho
        existing_cart_item = Cart.query.filter_by(product_id=product_id).first()

        if existing_cart_item:
            existing_cart_item.quantity += 1
            db.session.commit()
            return jsonify({"message": f"{product.name} quantity updated in cart!"}), 200
        else:
            new_cart_item = Cart(product_id=product.id)
            db.session.add(new_cart_item)
            db.session.commit()
            return jsonify({"message": f"{product.name} added to cart!"}), 201
    else:
        return jsonify({"message": "Product not found!"}), 404


#Novo endpoint pra ver o carrinho
#Assim o frontend pode fazer um fetch pra /cart e mostrar os produtos no carinho!
@app.route('/cart', methods=['GET'])
def get_cart():
    cart_items = Cart.query.all()
    cart_contents = []
    total_price = 0
    for item in cart_items:
        product = Product.query.get(item.product_id)
        if product:
            total_price += product.price * item.quantity
            cart_contents.append({
                "id": item.id,
                "product_id": product.id,
                "name": product.name,
                "price": product.price,
                "quantity": item.quantity
            })
    return jsonify({"items": cart_contents, "total": total_price}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
