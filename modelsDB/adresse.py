import uuid
from init_db import db

class Adresse(db.Model):
    __tablename__ = 'ADRESSE'

    id = db.Column('ID_Adresse', db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    street = db.Column('Rue', db.String(255), nullable=False)
    number = db.Column('Numero', db.String(255), nullable=False)
    city = db.Column('Localite', db.String(255), nullable=False)
    postalCode = db.Column('Code_postal', db.Numeric(5,0), nullable=False)
    country = db.Column('Pays', db.String(255), nullable=False)