from collections import defaultdict
from datetime import timedelta

from flask import Blueprint, render_template, g, flash, request, session, redirect, url_for
from sqlalchemy.exc import SQLAlchemyError
from modelsDB.figuration import Figuration, Compose, Location

from FigurUp.auth import login_required
from init_db import db

bp = Blueprint('profile', __name__, url_prefix='/profil')

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
        prix = float(tarif_heure) * duree

        if grouped[location_id]['date_heure'] is None:
            grouped[location_id]['date_heure'] = location.date_heure
            grouped[location_id]['date_fin'] = location.date_heure + timedelta(hours=duree)

        grouped[location_id]['tarif_heure'] += tarif_heure
        grouped[location_id]['duree'] = duree
        grouped[location_id]['prix'] += prix
        grouped[location_id]['caution'] += float(caution)
        nom = (
            figuration.fictif.nom if figuration.fictif else
            (figuration.celebrite.prenom + " " + figuration.celebrite.nom) if figuration.celebrite else
            figuration.animal.nom if figuration.animal else
            None
        )
        if nom:
            grouped[location_id]['names'].append(nom)

    resultats = []
    for data in grouped.values():
        data['name'] = ", ".join(data['names'])
        resultats.append(data)

    return render_template('profile/history.html', client=g.client, figurations=resultats)

@bp.route('/update', methods=['GET', 'POST'])
@login_required
def update():
    client = g.client
    if client.prive:
        form_type = 'particulier'
    elif client.professionnel:
        form_type = 'professionnel'
    else:
        form_type = 'particulier'

    if request.method == 'POST':
        data = request.form.to_dict()

        client.mail = data['mail']
        client.adresse.street = data['street']
        client.adresse.number = data['number']
        client.adresse.city = data['city']
        client.adresse.postalCode = data['postalCode']
        client.adresse.country = data['country']

        if form_type == 'particulier':
            client.prive.firstname = data['firstname']
            client.prive.lastname = data['lastname']
            client.prive.phone = data['phone']
        elif form_type == 'professionnel':
            client.professionnel.firstname = data['firstname']
            client.professionnel.lastname = data['lastname']
            client.professionnel.phone = data['phone']
            client.professionnel.name = data['name']
            client.professionnel.tva = data['tva']

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
    client = g.client
    try:
        db.session.delete(client)
        db.session.commit()
        session.clear()
        return redirect(url_for('auth.signin', deleted='true'))
    except SQLAlchemyError:
        db.session.rollback()
        flash("Une erreur est survenue lors de la suppression du compte.", "error")
        return redirect(url_for('profile.index'))

