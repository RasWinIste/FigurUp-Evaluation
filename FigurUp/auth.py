import functools
from sqlalchemy.exc import SQLAlchemyError
from flask import (
    Blueprint, render_template, request, url_for, redirect, flash, g, session
)
from werkzeug.security import generate_password_hash, check_password_hash
from init_db import db
from modelsDB.adresse import Adresse
from modelsDB.client import Client, Prive, Professionnel

bp = Blueprint('auth', __name__, url_prefix='/')

SIGNIN_PATH = 'auth/signin.html'

@bp.before_app_request
def load_logged_in_client():
    client_id = session.get('id')
    if client_id is None:
        g.client = None
    else:
        g.client = Client.query.get(client_id)

@bp.route('/inscription', methods=('GET', 'POST'))
def signin():
    form_type = request.args.get('type', 'particulier')

    if request.method == 'POST':
        data = request.form.to_dict()

        required_fields = ['firstname', 'lastname', 'mail', 'phone', 'password', 'street', 'number', 'city', 'postalCode', 'country']
        if form_type == 'professionnel':
            required_fields += ['name', 'tva']

        missing_fields = [field for field in required_fields if not data.get(field)]
        if missing_fields:
            flash('Tous les champs sont requis.', 'error')
            return render_template(SIGNIN_PATH, form_type=form_type, form_data=data)

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

            if form_type != 'professionnel':
                client = Client(
                    mail=data['mail'],
                    password=generate_password_hash(data['password'], method='pbkdf2:sha256'),
                    id_adresse=adresse.id,
                    professionnel_id=None,
                    prive_id='Prive'
                )
                db.session.add(client)
                db.session.flush()

                prive = Prive(id=client.id, lastname=data['lastname'], firstname=data['firstname'], phone=data['phone'])
                db.session.add(prive)
                client.prive_id = client.id

            else:
                client = Client(
                    mail=data['mail'],
                    password=generate_password_hash(data['password'], method='pbkdf2:sha256'),
                    id_adresse=adresse.id,
                    professionnel_id='Professionnel',
                    prive_id=None
                )
                db.session.add(client)
                db.session.flush()

                professionnel = Professionnel(
                    id=client.id,
                    name=data['name'],
                    tva=data['tva'],
                    lastname=data['lastname'],
                    firstname=data['firstname'],
                    phone=data['phone']
                )
                db.session.add(professionnel)
                client.professionnel_id = client.id

            db.session.commit()
            session['id'] = client.id
            return redirect(url_for('index'))

        except SQLAlchemyError as e:
            db.session.rollback()
            flash("Une erreur est survenue lors de l'inscription", "error")
            print("Erreur SQLAlchemy:", e)
            return render_template(SIGNIN_PATH, form_type=form_type, form_data=data)

    return render_template(SIGNIN_PATH, form_type=form_type)


@bp.route('/connexion', methods=('GET', 'POST'))
def login():
    if request.method == 'POST':
        data = request.form.to_dict()

        client = Client.query.filter_by(mail=data['mail']).first()

        if client and check_password_hash(client.password, data['password']):
            session['id'] = client.id
            return redirect(url_for('index'))
        else:
            flash("Identifiants incorrects", "error")

    return render_template('auth/login.html')

@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.client is None:
            return redirect(url_for('auth.login'))
        return view(**kwargs)
    return wrapped_view