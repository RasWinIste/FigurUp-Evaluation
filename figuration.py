from sqlalchemy.exc import SQLAlchemyError
from flask import (
    Blueprint, render_template, request, flash, g, session
)
from init_db import db
from modelsDB.figuration import Celebrite, Fictif, Animal, Figuration, Statique, Animatronique, Statut, Tiers
from modelsDB.client import Client
import uuid
bp = Blueprint('figuration', __name__, url_prefix='/figuration')

ADDING_PATH = 'figuration/adding.html'

@bp.route('/add', methods=('GET', 'POST'))
def adding():
    form_type = request.args.get('type', 'animatronique')
    select_type = request.args.get('spectype', 'fictif')

    if request.method == 'POST':
        data = request.form.to_dict()

        required_fields = ['size', 'pricing', 'caution', 'realsize']
        if form_type == 'animatronique':
            required_fields += ['battery', 'repairdate']
        if select_type == 'celebrity':
            required_fields += ['firstname', 'name', 'nationality', 'domain']
        elif select_type == 'fiction':
            required_fields += ['name', 'creator', 'universe']
        elif select_type == 'animal':
            required_fields += ['name', 'bioclass', 'habitat']

        missing_fields = [field for field in required_fields if not data.get(field)]
        if missing_fields:
            flash('Tous les champs sont requis.', 'error')
            return render_template(ADDING_PATH, form_type=form_type, form_data=data, select_type=select_type)

        try:
            statut = db.session.execute(
                db.select(Statut).filter_by(libelle='Disponible')
            ).scalar_one_or_none()

            tiers = db.session.execute(
                db.select(Tiers).filter_by(libelle='Tiers 1')
            ).scalar_one_or_none()

            figuration_id = str(uuid.uuid4())

            fig_type = ''
            if form_type == 'statique':
                fig_type = 'S'
            elif form_type == 'animatronique':
                fig_type = 'A'

            if select_type == 'celebrity':
                celebrity_id = str(uuid.uuid4())

                celebrite = Celebrite(
                    id=celebrity_id,
                    prenom=data['firstname'],
                    nom=data['name'],
                    taille_reelle=data['realsize'],
                    nationalite=data['nationality'],
                    domaine=data['domain']
                )
                db.session.add(celebrite)

                figuration = Figuration(
                    id=figuration_id,
                    taille=data['size'],
                    tarif_heure=data['pricing'],
                    caution=data['caution'],
                    id_statut=statut.id,
                    celebrite=celebrite,
                    id_tiers=tiers.id,
                    id_celebrite=celebrity_id,
                    type=fig_type
                )
                db.session.add(figuration)

            elif select_type == 'fiction':
                fictif_id = str(uuid.uuid4())

                fictif = Fictif(
                    id=fictif_id,
                    nom=data['name'],
                    taille_reelle=data['realsize'],
                    createur=data['creator'],
                    univers=data['universe']
                )
                db.session.add(fictif)

                figuration = Figuration(
                    id=figuration_id,
                    taille=data['size'],
                    tarif_heure=data['pricing'],
                    caution=data['caution'],
                    id_statut=statut.id,
                    fictif=fictif,
                    id_tiers=tiers.id,
                    id_fictif=fictif_id,
                    type=fig_type
                )
                db.session.add(figuration)

            elif select_type == 'animal':
                animal_id = str(uuid.uuid4())

                animal = Animal(
                    id=animal_id,
                    nom=data['name'],
                    taille_reelle=data['realsize'],
                    classe_bio=data['bioclass'],
                    habitat=data['habitat']
                )
                db.session.add(animal)

                figuration = Figuration(
                    id=figuration_id,
                    taille=data['size'],
                    tarif_heure=data['pricing'],
                    caution=data['caution'],
                    id_statut=statut.id,
                    animal=animal,
                    id_tiers=tiers.id,
                    id_animal=animal_id,
                    type=fig_type
                )
                db.session.add(figuration)

            db.session.flush()

            if form_type == 'statique':
                stat = Statique(
                    id=figuration_id,
                    type=fig_type
                )
                db.session.add(stat)
            elif form_type == 'animatronique':
                anim = Animatronique(
                    id=figuration_id,
                    niveau_batterie=data['battery'],
                    date_prochain_entretien=data['repairdate'],
                    type=fig_type
                )
                db.session.add(anim)

            db.session.flush()
            db.session.commit()
            session['id'] = figuration_id
            return render_template(ADDING_PATH, form_type=form_type, form_data=data, select_type=select_type)

        except SQLAlchemyError as e:
            db.session.rollback()
            flash("Une erreur est survenue lors de le création", "error")
            print("Erreur SQLAlchemy:", e)
            return render_template(ADDING_PATH, form_type=form_type, form_data=data, select_type=select_type)

    return render_template(ADDING_PATH, form_type=form_type, select_type=select_type)
