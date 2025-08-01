from flask import Blueprint, render_template, request, jsonify

from init_db import db
from modelsDB.figuration import Figuration, Animatronique

bp = Blueprint('technician', __name__, url_prefix='/technicien')

@bp.route('/batterie')
def index():
    figurations = Figuration.query.filter(
        Figuration.type == 'A'
    ).all()

    animatroniques = Animatronique.query.all()
    animatroniques_map = {a.id: a for a in animatroniques}

    for f in figurations:
        f.animatronique = animatroniques_map.get(f.id)
        if f.fictif:
            nom = f.fictif.nom
        elif f.celebrite:
            nom = f"{f.celebrite.prenom} {f.celebrite.nom}"
        elif f.animal:
            nom = f.animal.nom
        else:
            nom = ""
        f.nom = nom

    return render_template('technician/battery.html', fig_animatroniques=figurations)

@bp.route('/batterie/update/<id>', methods=['POST'])
def update_battery(id):
    data = request.get_json()
    nouveau_niveau = data.get('niveau_batterie')

    anim = Animatronique.query.get(id)
    if anim:
        anim.niveau_batterie = int(nouveau_niveau)
        db.session.commit()
        return jsonify({'success': True})
    return jsonify({'success': False}), 404