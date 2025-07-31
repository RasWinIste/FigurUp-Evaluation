from flask import Flask, render_template, session, redirect, url_for
import os
import pymysql

from auth import login_required
from init_db import db
from modelsDB.figuration import Figuration

pymysql.install_as_MySQLdb()

def create_app(test_config=None):
    app = Flask(__name__, instance_relative_config=True)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:password@localhost:3306/FigurUp'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SECRET_KEY'] = os.environ["SECRET_KEY"]

    db.init_app(app)

    from auth import bp
    from profile import bp as profile
    from figuration import bp as fig
    from location import bp as location
    from technician import bp as tech
    app.register_blueprint(bp)
    app.register_blueprint(fig)
    app.register_blueprint(profile)
    app.register_blueprint(location)
    app.register_blueprint(tech)

    app.add_url_rule('/', endpoint='index')

    if test_config is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_config)

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    @app.route('/')
    @login_required
    def index():
        figurations = Figuration.query.all()
        cards = session.get('cards', [])
        return render_template('index.html', figurations=figurations, cards=cards)

    @app.route('/cards/<fig_id>')
    @login_required
    def add_to_cards(fig_id):
        cards = session.get('cards', [])

        if fig_id not in cards:
            cards.append(fig_id)

        session['cards'] = cards
        return redirect(url_for('index'))

    return app
