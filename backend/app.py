from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS # type: ignore
from config import Config
import jwt
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app, resources={"/*": {"origins": "http://54.204.92.62"}})  # Frontend IP without port
app.config.from_object('config.Config')
app.config['SECRET_KEY'] = 'insecure'  # VERY INSECURE: DO NOT USE IN PRODUCTION


db = SQLAlchemy()

# ---------------- JWT HELPERS ----------------
def generate_token(user_id):
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(days=1)
    }
    return jwt.encode(payload, app.config['SECRET_KEY'], algorithm='HS256')

def decode_token(token):
    try:
        payload = jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

# ---------------- AUTH HELPER ----------------
def get_user_id_from_request():
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith("Bearer "):
        return None
    token = auth_header.split(" ")[1]
    return decode_token(token)


class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), nullable=False)
    password = db.Column(db.String(128), nullable=False)
    cart_items = db.relationship('Cart', back_populates='user', lazy=True)


class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    qty = db.Column(db.Integer)
    cart_items = db.relationship('Cart', back_populates='product', lazy=True)


class Cart(db.Model):
    __tablename__ = 'cart'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, default=1)
    user = db.relationship('User', back_populates='cart_items', lazy=True)
    product = db.relationship('Product', back_populates='cart_items', lazy=True)


db.init_app(app)

with app.app_context():
    db.create_all()


@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"message": "Username and password are required"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"message": "Username already exists"}), 409

    new_user = User(username=username, password=password)
    db.session.add(new_user)
    db.session.commit()

    token = generate_token(new_user.id)
    return jsonify({"message": "User created successfully", "token": token}), 201


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()

    if user and user.password == password:
        token = generate_token(user.id)
        return jsonify({"message": "Login successful!", "token": token}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401


@app.route('/products', methods=['GET'])
def get_products():
    products = Product.query.all()
    product_list = [{"id": p.id, "name": p.name, "price": p.price} for p in products]
    return jsonify(product_list), 200


@app.route('/addToCart', methods=['POST'])
def addToCart():
    user_id = get_user_id_from_request()
    if not user_id:
        return jsonify({"message": "Unauthorized"}), 401

    data = request.get_json()
    product_id = data.get('product_id')

    product = Product.query.get(product_id)
    if not product:
        return jsonify({"message": "Product not found!"}), 404

    existing_cart_item = Cart.query.filter_by(user_id=user_id, product_id=product_id).first()

    if existing_cart_item:
        existing_cart_item.quantity += 1
        db.session.commit()
        return jsonify({"message": f"{product.name} quantity updated in cart!"}), 200
    else:
        new_cart_item = Cart(user_id=user_id, product_id=product.id, quantity=1)
        db.session.add(new_cart_item)
        db.session.commit()
        return jsonify({"message": f"{product.name} added to cart!"}), 201




# Novo endpoint pra ver o carrinho
@app.route('/cart', methods=['GET'])
def get_cart():
    user_id = get_user_id_from_request()
    if not user_id:
        return jsonify({"message": "Unauthorized"}), 401

    cart_items = Cart.query.filter_by(user_id=user_id).all()
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

# Novo endpoint para seleção de método de pagamento
@app.route('/selectPayment', methods=['POST'])
def select_payment():
    data = request.get_json()
    payment_method = data.get('payment_method')

    if payment_method:
        return jsonify({"message": f"Payment method {payment_method} selected!"}), 200
    else:
        return jsonify({"message": "No payment method selected!"}), 400


# Novo endpoint para limpar o carrinho
@app.route('/admin/clearcart', methods=['POST'])
def clear_cart():
    try:
        Cart.query.delete()
        db.session.commit()
        return jsonify({"message": "Cart table cleared successfully!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
