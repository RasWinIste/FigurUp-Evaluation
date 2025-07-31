import uuid
from init_db import db

class Figuration(db.Model):
    __tablename__ = 'FIGURATION'

    id = db.Column('ID_Figuration', db.String(255), primary_key=True, default=lambda: str(uuid.uuid4()))
    taille = db.Column('Taille', db.String(255), nullable=False)
    tarif_heure = db.Column('Tarif_heure', db.String(255), nullable=False)
    caution = db.Column('Caution', db.String(255), nullable=False)
    id_statut = db.Column('ID_Statut', db.String(255), db.ForeignKey('STATUT.ID_Statut'), nullable=False)
    statique_id = db.Column('STATIQUE', db.String(255), db.ForeignKey('STATIQUE.ID_Figuration'))
    animatronique_id = db.Column('ANIMATRONIQUE', db.String(255), db.ForeignKey('ANIMATRONIQUE.ID_Figuration'))
    type = db.Column('TYPE', db.String(1), nullable=False)
    id_tiers = db.Column('ID_Tiers', db.String(255), db.ForeignKey('TIERS.ID_Tiers'), nullable=False)

    id_fictif = db.Column('ID_Fictif', db.String(255), db.ForeignKey('FICTIF.ID_Fictif'))
    id_animal = db.Column('ID_Animal', db.String(255), db.ForeignKey('ANIMAL.ID_Animal'))
    id_celebrite = db.Column('ID_Celebrite', db.String(255), db.ForeignKey('CELEBRITE.ID_Celebrite'))

    fictif = db.relationship("Fictif", backref="figuration", uselist=False)
    animal = db.relationship("Animal", backref="figuration", uselist=False)
    celebrite = db.relationship("Celebrite", backref="figuration", uselist=False)
    statique = db.relationship("Statique", backref="figuration", uselist=False)
    animatronique = db.relationship("Animatronique", backref="figuration", uselist=False)


class Statique(db.Model):
    __tablename__ = 'STATIQUE'
    id = db.Column('ID_Figuration', db.String(255), primary_key=True)
    type = db.Column('TYPE', db.String(1), nullable=False)

class Animatronique(db.Model):
    __tablename__ = 'ANIMATRONIQUE'
    id = db.Column('ID_Figuration', db.String(255), primary_key=True)
    niveau_batterie = db.Column('Niveau_batterie', db.String(255), nullable=False)
    date_prochain_entretien = db.Column('Date_prochain_entretien', db.String(255), nullable=False)
    type = db.Column('TYPE', db.String(1), nullable=False)

class Fictif(db.Model):
    __tablename__ = 'FICTIF'
    id = db.Column('ID_Fictif', db.String(255), primary_key=True)
    nom = db.Column('Nom', db.String(255), nullable=False)
    taille_reelle = db.Column('Taille_reelle', db.String(255), nullable=False)
    createur = db.Column('Createur', db.String(255), nullable=False)
    univers = db.Column('Univers', db.String(255), nullable=False)

class Celebrite(db.Model):
    __tablename__ = 'CELEBRITE'
    id = db.Column('ID_Celebrite', db.String(255), primary_key=True)
    prenom = db.Column('Prenom', db.String(255), nullable=False)
    nom = db.Column('Nom', db.String(255), nullable=False)
    taille_reelle = db.Column('Taille_reelle', db.String(255), nullable=False)
    nationalite = db.Column('Nationalite', db.String(255), nullable=False)
    domaine = db.Column('Domaine', db.String(255), nullable=False)

class Animal(db.Model):
    __tablename__ = 'ANIMAL'
    id = db.Column('ID_Animal', db.String(255), primary_key=True)
    nom = db.Column('Nom', db.String(255), nullable=False)
    taille_reelle = db.Column('Taille_reelle', db.String(255), nullable=False)
    classe_bio = db.Column('Classe_bio', db.String(255), nullable=False)
    habitat = db.Column('Habitat', db.String(255), nullable=False)

class Statut(db.Model):
    __tablename__ = 'STATUT'
    
    id = db.Column('ID_Statut', db.String(255), primary_key=True)
    libelle = db.Column('Libelle', db.String(255), nullable=False)
    
    figurations = db.relationship("Figuration", backref="statut")

class Tiers(db.Model):
    __tablename__ = 'TIERS'
    
    id = db.Column('ID_Tiers', db.String(255), primary_key=True)
    libelle = db.Column('Libelle', db.String(255), nullable=False)
    
    figurations = db.relationship("Figuration", backref="tiers")


class Location(db.Model):
    __tablename__ = 'LOCATION'

    id = db.Column('ID_Location', db.String(255), primary_key=True, default=lambda: str(uuid.uuid4()))
    date_heure = db.Column('Date_heure', db.String(255), nullable=False)
    duree = db.Column('Duree', db.String(255), nullable=False)
    date_paiement = db.Column('Date_paiement', db.String(255), nullable=False)
    id_client = db.Column('ID_Client', db.String(255), nullable=False)
    id_adresse = db.Column('ID_Adresse', db.String(255), nullable=False)

    compositions = db.relationship("Compose", back_populates="location", cascade="all, delete-orphan")

class Compose(db.Model):
    __tablename__ = 'COMPOSE'

    id_location = db.Column('ID_Location', db.String(255), db.ForeignKey('LOCATION.ID_Location'), primary_key=True)
    id_figuration = db.Column('ID_Figuration', db.String(255), db.ForeignKey('FIGURATION.ID_Figuration'), primary_key=True)
    etat_retour = db.Column('Etat_retour', db.String(255))

    location = db.relationship("Location", back_populates="compositions")
    figuration = db.relationship("Figuration")
