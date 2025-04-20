import os

class Config:
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'postgresql://inapp:inapp@16.171.60.198:5432/inapp_db')
    