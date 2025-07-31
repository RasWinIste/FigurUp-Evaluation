from datetime import datetime, timedelta
from decimal import Decimal

from flask import (
    Blueprint, g, session, render_template, request, jsonify, flash, url_for, redirect
)
from sqlalchemy import func, text
from sqlalchemy.exc import SQLAlchemyError

from init_db import db

from modelsDB.adresse import Adresse
from modelsDB.client import Client
from modelsDB.figuration import Figuration, Location, Compose

bp = Blueprint('location', __name__, url_prefix='/')


@bp.before_app_request
def load_logged_in_client():
    client_id = session.get('id')
    if client_id is None:
        g.client = None
    else:
        g.client = Client.query.get(client_id)


@bp.route('/calcul-prix', methods=['POST'])
def calcul_prix():
    var1 = 3;
    var2 = 5;

    var3 = var1 / var2;

    print(var3)
    
    data = request.get_json()
    start = datetime.fromisoformat(data['start'])
    end = datetime.fromisoformat(data['end'])

    if end <= start:
        return jsonify({'total': 0.0})

    duration_hours = (end - start).total_seconds() / 3600

    cards = session.get('cards', [])
    figures = Figuration.query.filter(Figuration.id.in_(cards)).all()

    total_caution = sum(f.caution for f in figures)
    total_tarif = sum(f.tarif_heure * Decimal(duration_hours) for f in figures)

    total_price = total_caution + total_tarif

    return jsonify({'total': float(total_price)})

@bp.route('/empty_cards', methods=['GET'])
def empty_cards():
    session['cards'] = []
    return render_template('location/location.html', figures=[], defaultBegin=datetime.now().strftime('%Y-%m-%dT%H:%M'))


@bp.route('/location', methods=('GET', 'POST'))
def location():
    cards = session.get('cards', [])
    figures = Figuration.query.filter(Figuration.id.in_(cards)).all()

    now = datetime.now().strftime('%Y-%m-%dT%H:%M')

    if request.method == 'POST':
        data = request.form.to_dict()

        if len(figures) == 0:
            flash('Le panier est vide.', 'error')
            return render_template('location/location.html', figures=figures, form_data=data,
                                   defaultBegin=now)

        missing_fields = [field for field in
                          ['street', 'number', 'city', 'postalCode', 'country', 'loc_start', 'loc_end'] if
                          not data.get(field)]
        if missing_fields:
            flash('Tous les champs sont requis.', 'error')
            return render_template('location/location.html', figures=figures, form_data=data,
                                   defaultBegin=now)

        start = datetime.fromisoformat(data['loc_start'])
        end = datetime.fromisoformat(data['loc_end'])
        duration_hours = (end - start).total_seconds() / 3600

        if start > end:
            flash("La date de début ne peut pas être avant la date de fin.", "error")
            return render_template('location/location.html', figures=figures, defaultBegin=now, form_data=data)

        conflict = unavailable_figure(start, end, cards)
        if conflict:
            flash("Des figurations ne sont pas disponible aux dates données.", "error")
            print(conflict)
            return render_template('location/location.html', figures=figures, defaultBegin=now, form_data=data, conflict=conflict)

        try:
            adresse = Adresse(
                street=data['street'],
                number=data['number'],
                city=data['city'],
                postalCode=data['postalCode'],
                country=data['country']
            )
            db.session.add(adresse)
            db.session.flush()

            location = Location(
                date_heure=data['loc_start'],
                duree=duration_hours,
                date_paiement=datetime.now().strftime('%Y-%m-%dT%H:%M'),
                id_client=session.get('id'),
                id_adresse=adresse.id
            )

            db.session.add(location)
            db.session.flush()

            for fig in figures:
                print(f"Insertion: location={location.id}, fig={fig.id}")

                comp = Compose(
                    id_location=location.id,
                    id_figuration=fig.id
                )
                db.session.add(comp)

            db.session.flush()
            db.session.commit()

            session['cards'] = []
            return redirect(url_for('index'))

        except SQLAlchemyError as e:
            db.session.rollback()
            flash("Une erreur est survenue lors de le création", "error")
            print("Erreur SQLAlchemy:", e)
            return render_template('location/location.html', form_data=data)

    return render_template('location/location.html', figures=figures, defaultBegin=now, cards=cards)

def unavailable_figure(start_datetime, end_datetime, ids_figurations):
    loc_end = func.timestampadd(text('HOUR'), Location.duree, Location.date_heure)

    conflicts = (
        db.session.query(Compose.id_figuration)
        .join(Location, Location.id == Compose.id_location)
        .filter(
            Compose.id_figuration.in_(ids_figurations),
            Location.date_heure < end_datetime,
            loc_end > start_datetime
        )
        .distinct()
        .all()
    )

    return [row[0] for row in conflicts]
