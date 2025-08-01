from collections import defaultdict
from datetime import timedelta

from flask import Blueprint, render_template, g, flash, request, session, redirect, url_for
from sqlalchemy.exc import SQLAlchemyError

from modelsDB.figuration import Figuration, Compose, Location
from FigurUp.auth import login_required
from init_db import db

bp = Blueprint('profile', __name__, url_prefix='/profil')


def get_name(figuration): 
    if figuration.fictif:
        return figuration.fictif.nom
    if figuration.celebrite:
        return f"{figuration.celebrite.prenom} {figuration.celebrite.nom}"
    if figuration.animal:
        return figuration.animal.nom
    return None


def determine_form_type(client):
    if client.prive:
        return 'particulier'
    if client.professionnel:
        return 'professionnel'
    return 'particulier'


@bp.route('/')
@login_required
def index():
    return render_template('profile/profile.html', client=g.client)


@bp.route('/history', methods=['GET', 'POST'])
@login_required
def history():
    client_id = g.client.id

    rows = (
        db.session.query(Location, Figuration.tarif_heure, Figuration.caution, Figuration)
        .join(Compose, Location.id == Compose.id_location)
        .join(Figuration, Compose.id_figuration == Figuration.id)
        .filter(Location.id_client == client_id)
        .order_by(Location.date_heure.desc())
        .all()
    )

    grouped = defaultdict(lambda: {
        'date_heure': None,
        'date_fin': None,
        'tarif_heure': 0,
        'duree': 0,
        'prix': 0.0,
        'caution': 0.0,
        'names': [],
    })

    for location, tarif_heure, caution, figuration in rows:
        location_id = location.id
        duree = float(location.duree)
        prix = tarif_heure * duree

        location_data = grouped[location_id]

        if location_data['date_heure'] is None:
            location_data['date_heure'] = location.date_heure
            location_data['date_fin'] = location.date_heure + timedelta(hours=duree)

        location_data['tarif_heure'] += tarif_heure
        location_data['duree'] = duree
        location_data['prix'] += prix
        location_data['caution'] += float(caution)

        nom = get_name(figuration)
        if nom:
            location_data['names'].append(nom)

    resultats = []
    for data in grouped.values():
        data['name'] = ", ".join(data['names'])
        resultats.append(data)

    return render_template('profile/history.html', client=g.client, figurations=resultats)


@bp.route('/update', methods=['GET', 'POST'])
@login_required
def update():
    client = g.client
    form_type = determine_form_type(client)

    if request.method == 'POST':
        data = request.form.to_dict()

        client.mail = data.get('mail')
        client.adresse.street = data.get('street')
        client.adresse.number = data.get('number')
        client.adresse.city = data.get('city')
        client.adresse.postalCode = data.get('postalCode')
        client.adresse.country = data.get('country')

        if form_type == 'particulier' and client.prive:
            client.prive.firstname = data.get('firstname')
            client.prive.lastname = data.get('lastname')
            client.prive.phone = data.get('phone')
        elif form_type == 'professionnel' and client.professionnel:
            client.professionnel.firstname = data.get('firstname')
            client.professionnel.lastname = data.get('lastname')
            client.professionnel.phone = data.get('phone')
            client.professionnel.name = data.get('name')
            client.professionnel.tva = data.get('tva')

        try:
            db.session.commit()
            flash("Profil mis à jour avec succès", "success")
        except SQLAlchemyError:
            db.session.rollback()
            flash("Erreur lors de la mise à jour du profil", "error")

    return render_template('profile/update.html', client=client, form_type=form_type)


@bp.route('/unsubscribe', methods=['POST'])
@login_required
def unsubscribe():
    try:
        db.session.delete(g.client)
        db.session.commit()
        session.clear()
        return redirect(url_for('auth.signin', deleted='true'))
    except SQLAlchemyError:
        db.session.rollback()
        flash("Une erreur est survenue lors de la suppression du compte.", "error")
        return redirect(url_for('profile.index'))
