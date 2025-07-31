import uuid
from init_db import db

class Client(db.Model):
    __tablename__ = 'CLIENT'

    id = db.Column('ID_Client', db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    mail = db.Column('Mail', db.String(255), nullable=False)
    password = db.Column('Mot_de_passe', db.String(255), nullable=False)
    id_adresse = db.Column('ID_Adresse', db.String(36), db.ForeignKey('ADRESSE.ID_Adresse'), nullable=False)
    professionnel_id = db.Column('PROFESSIONNEL', db.String(255), nullable=True)
    prive_id = db.Column('PRIVE', db.String(255), nullable=True)

    professionnel = db.relationship(
        "Professionnel", back_populates="client", uselist=False,
        cascade="all, delete-orphan", single_parent=True
    )
    prive = db.relationship(
        "Prive", back_populates="client", uselist=False,
        cascade="all, delete-orphan", single_parent=True
    )
    adresse = db.relationship(
        "Adresse", backref="clients", uselist=False,
        passive_deletes=True, single_parent=True
    )


class Professionnel(db.Model):
    __tablename__ = 'PROFESSIONNEL'

    id = db.Column('ID_Client', db.String(36), db.ForeignKey('CLIENT.ID_Client'), primary_key=True)
    name = db.Column('Nom_entreprise', db.String(255), nullable=False)
    tva = db.Column('TVA', db.String(255), nullable=False)
    lastname = db.Column('Contact_Nom', db.String(255), nullable=False)
    firstname = db.Column('Contact_Prenom', db.String(255), nullable=False)
    phone = db.Column('Contact_Telephone', db.String(255), nullable=False)

    client = db.relationship("Client", back_populates="professionnel")

class Prive(db.Model):
    __tablename__ = 'PRIVE'

    id = db.Column('ID_Client', db.String(36), db.ForeignKey('CLIENT.ID_Client'), primary_key=True)
    lastname = db.Column('Nom', db.String(255), nullable=False)
    firstname = db.Column('Prenom', db.String(255), nullable=False)
    phone = db.Column('Telephone', db.String(255), nullable=False)

    client = db.relationship("Client", back_populates="prive")



