## Código relacionado com o backend da applicação e API

from flask import Flask, request, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS  # type: ignore
from config import Config

app = Flask(__name__)
CORS(app, resources={"/*": {"origins": "http://54.204.92.62"}}) # Frontend IP without port
app.config.from_object('config.Config')

db = SQLAlchemy() 

class User (db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    password = db.Column(db.String(128), nullable=False)
    cart_items = db.relationship('Cart', backref='user', lazy=True)

class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    price = db.Column(db.Float, nullable=False)
    qty = db.Column(db.Integer)
    cart_items = db.relationship('Cart', lazy=True)

class Cart(db.Model):
    __tablename__ = 'cart'
    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, default=1)

    # Para facilitar a busca do produto associado
    product = db.relationship('Product', backref='cart_entries', lazy=True)

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

    new_user = User(username=username, password=password) # Store plain-text password
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "User created successfully"}), 201


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()

    if user and user.password == password: 
        session['user_id'] = user.id
        return jsonify({"message": "Logged in successfully!"}), 200
    else:
        return jsonify({"message": "Username or password is incorrect"}), 401
    
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
