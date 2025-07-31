create table ADRESSE (
     ID_Adresse char(36) not null DEFAULT (UUID()),
     Rue char(255) not null,
     Numero char(255) not null,
     Localite char(255) not null,
     Code_postal decimal not null,
     Pays char(255) not null,
     constraint ID_ADRESSE_ID primary key (ID_Adresse));

create table ANIMAL (
     ID_Animal char(36) not null DEFAULT (UUID()),
     Nom char(255) not null,
     Taille_reelle decimal not null,
     Classe_bio char(255) not null,
     Habitat char(255) not null,
     constraint ID_ANIMAL_ID primary key (ID_Animal));

create table ANIMATRONIQUE (
     ID_Figuration char(36) not null,
     Niveau_batterie decimal not null,
     Date_prochain_entretien datetime not null,
     TYPE char(1) default 'A' not null,
     constraint check ( TYPE = 'A' ),
     constraint ID_ANIMA_FIGUR_ID primary key (ID_Figuration));

create table CELEBRITE (
     ID_Celebrite char(36) not null DEFAULT (UUID()),
     Prenom char(255) not null,
     Nom char(255) not null,
     Taille_reelle decimal not null,
     Nationalite char(255) not null,
     Domaine char(255) not null,
     constraint ID_CELEBRITE_ID primary key (ID_Celebrite));

create table CLIENT (
     ID_Client char(36) not null DEFAULT (UUID()),
     Mail char(255) not null unique,
     Mot_de_passe char(255) not null,
     ID_Adresse char(36) not null,
     PROFESSIONNEL char(255),
     PRIVE char(255),
     constraint ID_CLIENT_ID primary key (ID_Client));

create table COMPOSE (
     ID_Location char(36) not null,
     Etat_retour ENUM('bon', 'maintenance'),
     ID_Figuration char(36) not null,
     constraint ID_COMPO_LOCAT_ID primary key (ID_Location,ID_Figuration));

create table CONSISTE (
     ID_Materiaux char(36) not null,
     ID_Figuration char(36) not null,
     constraint ID_CONSISTE_ID primary key (ID_Figuration, ID_Materiaux));

create table ENTRETIEN (
     ID_Entretien char(36) not null DEFAULT (UUID()),
     Date_heure datetime not null,
     Description char(255) not null,
     Duree decimal not null,
     Cout decimal not null,
     ID_Figuration char(36) not null,
     ID_Technicien char(36) not null,
     constraint ID_ENTRETIEN_ID primary key (ID_Entretien));

create table FABRICANT (
     ID_Fabricant char(36) not null DEFAULT (UUID()),
     Nom char(255) not null,
     ID_Adresse char(36) not null,
     constraint ID_FABRICANT_ID primary key (ID_Fabricant));

create table FABRICATION (
     ID_Figuration char(36) not null,
     Date_fabrication date not null,
     ID_Fabricant char(36) not null,
     constraint ID_FABRI_FIGUR_ID primary key (ID_Figuration));

create table FACTURE (
     ID_Location char(36) not null,
     Adresse_facturation char(255) not null,
     ID_Adresse char(36) not null,
     ID_Client char(36),
     constraint ID_FACTU_LOCAT_ID primary key (ID_Location));

create table FICTIF (
     ID_Fictif char(36) not null DEFAULT (UUID()),
     Nom char(255) not null,
     Taille_reelle decimal not null,
     Createur char(255) not null,
     Univers char(255) not null,
     constraint ID_FICTIF_ID primary key (ID_Fictif));

create table FIGURATION (
     ID_Figuration char(36) not null DEFAULT (UUID()),
     Taille decimal not null,
     Tarif_heure decimal not null,
     Caution decimal not null,
     TYPE char(1) not null default '',
     ID_Statut char(36) not null,
     STATIQUE char(255),
     ANIMATRONIQUE char(255),
     ID_Tiers char(36) not null,
     ID_Fictif char(36),
     ID_Animal char(36),
     ID_Celebrite char(36),
     constraint unique (ID_Figuration,TYPE),
     constraint check ( TYPE in ('S','A','') ),
     constraint ID_FIGURATION_ID primary key (ID_Figuration));

create table LOCATION (
     ID_Location char(36) not null DEFAULT (UUID()),
     Date_heure datetime not null,
     Duree decimal not null,
     Date_paiement datetime not null,
     ID_Client char(36),
     ID_Adresse char(36) not null,
     constraint ID_LOCATION_ID primary key (ID_Location));

create table MATERIAUX (
     ID_Materiaux char(36) not null DEFAULT (UUID()),
     Nom char(255) not null,
     Temp_min decimal not null,
     Temp_max decimal not null,
     Exterieur boolean not null,
     constraint ID_MATERIAUX_ID primary key (ID_Materiaux));

create table PRIVE (
     ID_Client char(36) not null,
     Nom char(255) not null,
     Prenom char(255) not null,
     Telephone char(255) not null,
     constraint ID_PRIVE_CLIEN_ID primary key (ID_Client));

create table PROFESSIONNEL (
     ID_Client char(36) not null,
     Nom_entreprise char(255) not null,
     TVA char(255) not null,
     Contact_Nom char(255) not null,
     Contact_Prenom char(255) not null,
     Contact_Telephone char(255) not null,
     constraint ID_PROFE_CLIEN_ID primary key (ID_Client));

create table SPECIALISE (
     ID_Specialite char(36) not null,
     ID_Technicien char(36) not null,
     constraint ID_SPECIALISE_ID primary key (ID_Technicien, ID_Specialite));

create table SPECIALITE (
     ID_Specialite char(36) not null DEFAULT (UUID()),
     Libelle char(255) not null,
     constraint ID_SPECIALITE_ID primary key (ID_Specialite));

create table STATIQUE (
     ID_Figuration char(36) not null,
     TYPE char(1) default 'S' not null,
     constraint check (TYPE = 'S'),
     constraint ID_STATI_FIGUR_ID primary key (ID_Figuration));

create table STATUT (
     ID_Statut char(36) not null DEFAULT (UUID()),
     Libelle char(255) not null,
     constraint ID_STATUT_ID primary key (ID_Statut));

create table TECHNICIEN (
     ID_Technicien char(36) not null DEFAULT (UUID()),
     Nom char(255) not null,
     Prenom char(255) not null,
     constraint ID_TECHNICIEN_ID primary key (ID_Technicien));

create table TIERS (
     ID_Tiers char(36) not null DEFAULT (UUID()),
     Libelle char(255) not null,
     constraint ID_TIERS_ID primary key (ID_Tiers));


-- Constraints Section
-- ___________________

alter table ANIMATRONIQUE add constraint ID_ANIMA_FIGUR_FK
     foreign key (ID_Figuration,TYPE)
     references FIGURATION (ID_Figuration,TYPE);

alter table CLIENT add constraint EXTONE_CLIENT
     check((PROFESSIONNEL is not null and PRIVE is null)
           or (PROFESSIONNEL is null and PRIVE is not null));

alter table CLIENT add constraint REF_CLIEN_ADRES_FK
     foreign key (ID_Adresse)
     references ADRESSE (ID_Adresse);

alter table COMPOSE add constraint REF_COMPO_LOCAT_FK
     foreign key (ID_Location)
     references LOCATION (ID_Location);

alter table COMPOSE add constraint REF_COMPO_FIGUR_FK
     foreign key (ID_Figuration)
     references FIGURATION (ID_Figuration);

alter table CONSISTE add constraint EQU_CONSI_STATI
     foreign key (ID_Figuration)
     references STATIQUE (ID_Figuration);

alter table CONSISTE add constraint REF_CONSI_MATER_FK
     foreign key (ID_Materiaux)
     references MATERIAUX (ID_Materiaux);

alter table ENTRETIEN add constraint REF_ENTRE_FIGUR_FK
     foreign key (ID_Figuration)
     references FIGURATION (ID_Figuration);

alter table ENTRETIEN add constraint REF_ENTRE_TECHN_FK
     foreign key (ID_Technicien)
     references TECHNICIEN (ID_Technicien);

alter table FABRICANT add constraint REF_FABRI_ADRES_FK
     foreign key (ID_Adresse)
     references ADRESSE (ID_Adresse);

alter table FABRICATION add constraint ID_FABRI_FIGUR_FK
     foreign key (ID_Figuration)
     references FIGURATION (ID_Figuration);

alter table FABRICATION add constraint REF_FABRI_FABRI_FK
     foreign key (ID_Fabricant)
     references FABRICANT (ID_Fabricant);

alter table FACTURE add constraint ID_FACTU_LOCAT_FK
     foreign key (ID_Location)
     references LOCATION (ID_Location);

alter table FACTURE add constraint REF_FACTU_ADRES_FK
     foreign key (ID_Adresse)
     references ADRESSE (ID_Adresse);

alter table FACTURE add constraint REF_FACTU_PROFE_FK
     foreign key (ID_Client)
     references PROFESSIONNEL (ID_Client);

alter table FIGURATION add constraint EXTONE_FIGURATION
     check((ID_Celebrite is not null and ID_Fictif is null and ID_Animal is null)
           or (ID_Celebrite is null and ID_Fictif is not null and ID_Animal is null)
           or (ID_Celebrite is null and ID_Fictif is null and ID_Animal is not null));

alter table FIGURATION add constraint EXCL_FIGURATION
     check((ANIMATRONIQUE is not null and STATIQUE is null)
           or (ANIMATRONIQUE is null and STATIQUE is not null)
           or (ANIMATRONIQUE is null and STATIQUE is null));

alter table FIGURATION add constraint REF_FIGUR_STATU_FK
     foreign key (ID_Statut)
     references STATUT (ID_Statut);

alter table FIGURATION add constraint REF_FIGUR_TIERS_FK
     foreign key (ID_Tiers)
     references TIERS (ID_Tiers);

alter table FIGURATION add constraint REF_FIGUR_FICTI_FK
     foreign key (ID_Fictif)
     references FICTIF (ID_Fictif);

alter table FIGURATION add constraint REF_FIGUR_ANIMA_FK
     foreign key (ID_Animal)
     references ANIMAL (ID_Animal);

alter table FIGURATION add constraint REF_FIGUR_CELEB_FK
     foreign key (ID_Celebrite)
     references CELEBRITE (ID_Celebrite);

alter table LOCATION add constraint REF_LOCAT_CLIEN_FK
     foreign key (ID_Client)
     references CLIENT (ID_Client);

alter table LOCATION add constraint REF_LOCAT_ADRES_FK
     foreign key (ID_Adresse)
     references ADRESSE (ID_Adresse);

alter table PRIVE add constraint ID_PRIVE_CLIEN_FK
     foreign key (ID_Client)
     references CLIENT (ID_Client);

alter table PROFESSIONNEL add constraint ID_PROFE_CLIEN_FK
     foreign key (ID_Client)
     references CLIENT (ID_Client);

alter table SPECIALISE add constraint EQU_SPECI_TECHN
     foreign key (ID_Technicien)
     references TECHNICIEN (ID_Technicien);

alter table SPECIALISE add constraint REF_SPECI_SPECI_FK
     foreign key (ID_Specialite)
     references SPECIALITE (ID_Specialite);

alter table STATIQUE add constraint ID_STATI_FIGUR_FK
     foreign key (ID_Figuration, TYPE)
     references FIGURATION (ID_Figuration, TYPE);

-- Index Section
-- _____________

create unique index ID_ADRESSE_IND
     on ADRESSE (ID_Adresse);

create index KEY_ADRESSE
     on ADRESSE (Localite);

create unique index ID_ANIMAL_IND
     on ANIMAL (ID_Animal);

create index KEY_ANIMAL
     on ANIMAL (Habitat);

create unique index ID_ANIMA_FIGUR_IND
     on ANIMATRONIQUE (ID_Figuration);

create unique index ID_CELEBRITE_IND
     on CELEBRITE (ID_Celebrite);

create index KEY_CELEBRITE
     on CELEBRITE (Domaine);

create unique index ID_CLIENT_IND
     on CLIENT (ID_Client);

create index REF_CLIEN_ADRES_IND
     on CLIENT (ID_Adresse);

create index KEY_CLIENT
     on CLIENT (Mail);

create index REF_COMPO_LOCAT_IND
     on COMPOSE (ID_Location);

create index REF_COMPO_FIGUR_IND
     on COMPOSE (ID_Figuration);

create unique index ID_CONSISTE_IND
     on CONSISTE (ID_Figuration, ID_Materiaux);

create index REF_CONSI_MATER_IND
     on CONSISTE (ID_Materiaux);

create unique index ID_ENTRETIEN_IND
     on ENTRETIEN (ID_Entretien);

create index REF_ENTRE_FIGUR_IND
     on ENTRETIEN (ID_Figuration);

create index REF_ENTRE_TECHN_IND
     on ENTRETIEN (ID_Technicien);

create index KEY_ENTRETIEN
     on ENTRETIEN (Date_heure);

create unique index ID_FABRICANT_IND
     on FABRICANT (ID_Fabricant);

create index REF_FABRI_ADRES_IND
     on FABRICANT (ID_Adresse);

create unique index ID_FABRI_FIGUR_IND
     on FABRICATION (ID_Figuration);

create index REF_FABRI_FABRI_IND
     on FABRICATION (ID_Fabricant);

create unique index ID_FACTU_LOCAT_IND
     on FACTURE (ID_Location);

create index REF_FACTU_ADRES_IND
     on FACTURE (ID_Adresse);

create index REF_FACTU_PROFE_IND
     on FACTURE (ID_Client);

create unique index ID_FICTIF_IND
     on FICTIF (ID_Fictif);

create index KEY_FICTIF
     on FICTIF (Univers);

create unique index ID_FIGURATION_IND
     on FIGURATION (ID_Figuration);

create index REF_FIGUR_STATU_IND
     on FIGURATION (ID_Statut);

create index REF_FIGUR_TIERS_IND
     on FIGURATION (ID_Tiers);

create index REF_FIGUR_FICTI_IND
     on FIGURATION (ID_Fictif);

create index REF_FIGUR_ANIMA_IND
     on FIGURATION (ID_Animal);

create index REF_FIGUR_CELEB_IND
     on FIGURATION (ID_Celebrite);

create index KEY_FIGURATION
     on FIGURATION (Tarif_heure);

create unique index ID_LOCATION_IND
     on LOCATION (ID_Location);

create index REF_LOCAT_CLIEN_IND
     on LOCATION (ID_Client);

create index REF_LOCAT_ADRES_IND
     on LOCATION (ID_Adresse);

create index KEY_LOCATION
     on LOCATION (Date_heure);

create unique index ID_MATERIAUX_IND
     on MATERIAUX (ID_Materiaux);

create unique index ID_PRIVE_CLIEN_IND
     on PRIVE (ID_Client);

create unique index ID_PROFE_CLIEN_IND
     on PROFESSIONNEL (ID_Client);

create index KEY_PROFESSIONNEL
     on PROFESSIONNEL (TVA);

create unique index ID_SPECIALISE_IND
     on SPECIALISE (ID_Technicien, ID_Specialite);

create index REF_SPECI_SPECI_IND
     on SPECIALISE (ID_Specialite);

create unique index ID_SPECIALITE_IND
     on SPECIALITE (ID_Specialite);

create unique index ID_STATI_FIGUR_IND
     on STATIQUE (ID_Figuration);

create unique index ID_STATUT_IND
     on STATUT (ID_Statut);

create unique index ID_TECHNICIEN_IND
     on TECHNICIEN (ID_Technicien);

create unique index ID_TIERS_IND
     on TIERS (ID_Tiers);

--
-- Default data --
--
SET NAMES utf8mb4;

insert into TIERS (Libelle) values ('Tiers 1');
insert into TIERS (Libelle) values ('Tiers 2');
insert into TIERS (Libelle) values ('Tiers 3');

insert into STATUT (Libelle) values ('Disponible');
insert into STATUT (Libelle) values ('Maintenance');
insert into STATUT (Libelle) values ('Loué');
insert into STATUT (Libelle) values ('Batterie_faible');

insert into ADRESSE (Rue, Numero, Localite, Code_postal, Pays) values ('Chaussée romaine', '25', 'Bruxelles', 1020, 'Belgique');
insert into ADRESSE (Rue, Numero, Localite, Code_postal, Pays) values ('Rue de la Station', '14A', 'Namur', 5000, 'Belgique');
insert into ADRESSE (Rue, Numero, Localite, Code_postal, Pays) values ('Rue Saint-Gilles', '88', 'Liège', 4000, 'Belgique');
insert into ADRESSE (Rue, Numero, Localite, Code_postal, Pays) values ('Rue de l’Université', '21', 'Louvain-la-Neuve', 1348, 'Belgique');

insert into FABRICANT (Nom, ID_Adresse)
select 'NeuroMech Dynamics', ID_Adresse
from ADRESSE
where Localite = 'Bruxelles';

insert into FABRICANT (Nom, ID_Adresse)
select 'MecaPulse Robotics', ID_Adresse
from ADRESSE
where Localite = 'Louvain-la-Neuve';

insert into TECHNICIEN (Nom, Prenom) values ('Dupont', 'Bob');
insert into TECHNICIEN (Nom, Prenom) values ('Dupond', 'Pierre');
insert into TECHNICIEN (Nom, Prenom) values ('Dumont', 'Paul');

insert into SPECIALITE (Libelle) values ('robotique');
insert into SPECIALITE (Libelle) values ('électronique');
insert into SPECIALITE (Libelle) values ('programmation');
insert into SPECIALITE (Libelle) values ('systèmes audio');

insert into SPECIALISE (ID_Specialite, ID_Technicien)
select
    (select ID_Specialite from SPECIALITE where Libelle = 'robotique'),
    (select ID_Technicien from TECHNICIEN where Nom = 'Dupont' and Prenom = 'Bob')
;
insert into SPECIALISE (ID_Specialite, ID_Technicien)
select
    (select ID_Specialite from SPECIALITE where Libelle = 'électronique'),
    (select ID_Technicien from TECHNICIEN where Nom = 'Dupont' and Prenom = 'Bob')
;
insert into SPECIALISE (ID_Specialite, ID_Technicien)
select
    (select ID_Specialite from SPECIALITE where Libelle = 'programmation'),
    (select ID_Technicien from TECHNICIEN where Nom = 'Dupond' and Prenom = 'Pierre')
;
insert into SPECIALISE (ID_Specialite, ID_Technicien)
select
    (select ID_Specialite from SPECIALITE where Libelle = 'systèmes audio'),
    (select ID_Technicien from TECHNICIEN where Nom = 'Dumont' and Prenom = 'Paul')
;

insert into MATERIAUX (Nom, Temp_min, Temp_max, Exterieur) values ('Aluminium', -40, 100, true);
insert into MATERIAUX (Nom, Temp_min, Temp_max, Exterieur) values ('Acier inoxydable', -50, 120, true);
insert into MATERIAUX (Nom, Temp_min, Temp_max, Exterieur) values ('Plastique ABS', 0, 60, false);
insert into MATERIAUX (Nom, Temp_min, Temp_max, Exterieur) values ('Caoutchouc synthétique', -20, 70, true);

insert into ANIMAL (Nom, Taille_reelle, Classe_bio, Habitat) values ('Lion', 120, 'Mammifère', 'Savane');
insert into ANIMAL (Nom, Taille_reelle, Classe_bio, Habitat) values ('Éléphant d Afrique', 330, 'Mammifère', 'Savane et forêt tropicale');
insert into FICTIF (Nom, Taille_reelle, Createur, Univers) values ('Mario', 120, 'Shigeru Miyamoto', 'Super Mario');
insert into FICTIF (Nom, Taille_reelle, Createur, Univers) values ('Sonic', 100, 'Naoto Ohshima', 'Sonic the Hedgehog');
insert into CELEBRITE (Prenom, Nom, Taille_reelle, Nationalite, Domaine) values ('Tom', 'Hanks', 183, 'Américaine', 'Acteur');
insert into CELEBRITE (Prenom, Nom, Taille_reelle, Nationalite, Domaine) values ('Rafael', 'Nadal', 185, 'Espagnol', 'Tennis');

insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df74204f-3579-11f0-a9c4-5a7d32a6f653',120, 50, 100, (select ID_Statut from STATUT where Libelle = 'Disponible'), null, 'df74204f-3579-11f0-a9c4-5a7d32a6f653', (select ID_Tiers from TIERS where Libelle = 'Tiers 2'), (select ID_Fictif from FICTIF where Nom = 'Mario'), null, null, 'A');
insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df7430a2-3579-11f0-a9c4-5a7d32a6f653', 100, 20, 100, (select ID_Statut from STATUT where Libelle = 'Maintenance'), null, 'df7430a2-3579-11f0-a9c4-5a7d32a6f653', (select ID_Tiers from TIERS where Libelle = 'Tiers 3'), (select ID_Fictif from FICTIF where Nom = 'Sonic'), null, null, 'A');
insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df744f52-3579-11f0-a9c4-5a7d32a6f653', 120, 50, 100, (select ID_Statut from STATUT where Libelle = 'Loué'), null, 'df744f52-3579-11f0-a9c4-5a7d32a6f653', (select ID_Tiers from TIERS where Libelle = 'Tiers 2'), null, (select ID_Animal from ANIMAL where Nom = 'Lion'), null, 'A');
insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df7462c4-3579-11f0-a9c4-5a7d32a6f653', 330, 80, 200, (select ID_Statut from STATUT where Libelle = 'Disponible'), null, 'df7462c4-3579-11f0-a9c4-5a7d32a6f653', (select ID_Tiers from TIERS where Libelle = 'Tiers 1'), null, (select ID_Animal from ANIMAL where Nom = 'Éléphant d Afrique'), null, 'A');
insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df74754c-3579-11f0-a9c4-5a7d32a6f653', 183, 80, 200, (select ID_Statut from STATUT where Libelle = 'Maintenance'), 'df74754c-3579-11f0-a9c4-5a7d32a6f653', null, (select ID_Tiers from TIERS where Libelle = 'Tiers 1'), null, null, (select ID_Celebrite from CELEBRITE where Nom = 'Hanks'), 'S');
insert into FIGURATION (ID_Figuration, Taille, Tarif_heure, Caution, ID_Statut, STATIQUE, ANIMATRONIQUE, ID_Tiers, ID_Fictif, ID_Animal, ID_Celebrite, TYPE)
values ('df7486a6-3579-11f0-a9c4-5a7d32a6f653',185, 80, 200, (select ID_Statut from STATUT where Libelle = 'Loué'), 'df7486a6-3579-11f0-a9c4-5a7d32a6f653', null, (select ID_Tiers from TIERS where Libelle = 'Tiers 1'), null, null, (select ID_Celebrite from CELEBRITE where Nom = 'Nadal'), 'S');

insert into STATIQUE (ID_Figuration, TYPE) values ((select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Hanks')), 'S');
insert into STATIQUE (ID_Figuration, TYPE) values ((select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Nadal')), 'S');

insert into ANIMATRONIQUE (ID_Figuration, Niveau_batterie, Date_prochain_entretien) values ((select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Mario')), 85, '2025-07-10');
insert into ANIMATRONIQUE (ID_Figuration, Niveau_batterie, Date_prochain_entretien) values ((select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Sonic')), 25, '2025-06-20');
insert into ANIMATRONIQUE (ID_Figuration, Niveau_batterie, Date_prochain_entretien) values ((select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Éléphant d Afrique')), 95, '2025-07-25');
insert into ANIMATRONIQUE (ID_Figuration, Niveau_batterie, Date_prochain_entretien) values ((select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Lion')), 75, '2025-08-10');

insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Mario')), '2024-01-06', (select ID_Fabricant from FABRICANT where Nom = 'MecaPulse Robotics'));
insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Fictif =(select ID_Fictif from FICTIF where Nom = 'Sonic')), '2024-02-10', (select ID_Fabricant from FABRICANT where Nom = 'MecaPulse Robotics'));
insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Hanks')), '2024-03-12', (select ID_Fabricant from FABRICANT where Nom = 'MecaPulse Robotics'));
insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Nadal')), '2024-04-05', (select ID_Fabricant from FABRICANT where Nom = 'MecaPulse Robotics'));
insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Éléphant d Afrique')), '2024-01-15', (select ID_Fabricant from FABRICANT where Nom = 'NeuroMech Dynamics'));
insert into FABRICATION (ID_Figuration, Date_fabrication, ID_Fabricant)
values ((select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Lion')), '2024-02-20', (select ID_Fabricant from FABRICANT where Nom = 'NeuroMech Dynamics'));

insert into ENTRETIEN (Date_heure, Description, Duree, Cout, ID_Figuration, ID_Technicien)
values ('2025-04-10 15:30:00','Révision complète du moteur et recalibrage des capteurs',120,250, (select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Mario')), (select ID_Technicien from TECHNICIEN where Nom = 'Dupont'));
insert into ENTRETIEN (Date_heure, Description, Duree, Cout, ID_Figuration, ID_Technicien)
values ('2024-04-12 10:00:00','Remplacement partiel du sytème audio',90,180, (select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Sonic')), (select ID_Technicien from TECHNICIEN where Nom = 'Dumont'));
insert into ENTRETIEN (Date_heure, Description, Duree, Cout, ID_Figuration, ID_Technicien)
values ('2024-04-15 09:00:00','Mise à jour du firmware',60,150, (select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Lion')), (select ID_Technicien from TECHNICIEN where Nom = 'Dupond'));
insert into ENTRETIEN (Date_heure, Description, Duree, Cout, ID_Figuration, ID_Technicien)
values ('2025-04-18 14:00:00','Contrôle général et remplacement de la batterie secondaire',150,320.00, (select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Éléphant d Afrique')), (select ID_Technicien from TECHNICIEN where Nom = 'Dupont'));

-- mot de passe : test123
insert into CLIENT (ID_Client, Mail, Mot_de_passe, ID_Adresse, PROFESSIONNEL, PRIVE) values ('18d4af13-2a8b-11f0-8f96-2aa604c0110e', 'john.doe@test.dev', 'pbkdf2:sha256:1000000$rpDeOcr8rYPYAixM$fbaec36f190c121b4a9f9bca1c9609a8d90d044ad9917b603aac9f2ec23f5584', (select ID_Adresse from ADRESSE where Localite = 'Namur'), null, '18d4af13-2a8b-11f0-8f96-2aa604c0110e');
insert into PRIVE (ID_Client, Nom, Prenom, Telephone) values ('18d4af13-2a8b-11f0-8f96-2aa604c0110e', 'Doe', 'John', '+3204000000');

insert into CLIENT (ID_Client, Mail, Mot_de_passe, ID_Adresse, PROFESSIONNEL, PRIVE) values ('18d4cedc-2a8b-11f0-8f96-2aa604c0110e', 'martin.dupont@test.dev', 'pbkdf2:sha256:1000000$rpDeOcr8rYPYAixM$fbaec36f190c121b4a9f9bca1c9609a8d90d044ad9917b603aac9f2ec23f5584', (select ID_Adresse from ADRESSE where Localite = 'Liège'), '18d4cedc-2a8b-11f0-8f96-2aa604c0110e', null);
insert into PROFESSIONNEL (ID_Client, Nom_entreprise, TVA, Contact_Nom, Contact_Prenom, Contact_Telephone) values ('18d4cedc-2a8b-11f0-8f96-2aa604c0110e', 'CyberTech', 'BE0123654789', 'Dupont', 'Martin', '+3205000000');

insert into CONSISTE (ID_Materiaux, ID_Figuration)
values (
    (select ID_Materiaux from MATERIAUX where Nom = 'Plastique ABS'),
    (select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Hanks'))
);

insert into CONSISTE (ID_Materiaux, ID_Figuration)
values (
    (select ID_Materiaux from MATERIAUX where Nom = 'Aluminium'),
    (select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Nadal'))
);

insert into LOCATION (Date_heure, Duree, Date_paiement, ID_Client, ID_Adresse)
values (
    '2024-05-01 10:00:00',
    6,
    '2024-05-02',
    (select ID_Client from CLIENT where Mail = 'john.doe@test.dev'),
    (select ID_Adresse from ADRESSE where Localite = 'Namur')
);
insert into LOCATION (Date_heure, Duree, Date_paiement, ID_Client, ID_Adresse)
values (
    '2025-03-03 14:30:00',
    2,
    '2025-03-04',
    (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev'),
    (select ID_Adresse from ADRESSE where Localite = 'Liège')
);
insert into LOCATION (Date_heure, Duree, Date_paiement, ID_Client, ID_Adresse)
values (
    '2025-05-05 09:00:00',
    3,
    '2025-05-06',
    (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev'),
    (select ID_Adresse from ADRESSE where Localite = 'Bruxelles')
);
insert into LOCATION (Date_heure, Duree, Date_paiement, ID_Client, ID_Adresse)
values (
    '2024-08-07 16:00:00',
    4,
    '2024-08-07',
    (select ID_Client from CLIENT where Mail = 'john.doe@test.dev'),
    (select ID_Adresse from ADRESSE where Localite = 'Namur')
);

insert into COMPOSE (ID_Location, Etat_retour, ID_Figuration)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'john.doe@test.dev') and Date_heure = '2024-05-01 10:00:00'),
    'bon',
    (select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Mario'))
);
insert into COMPOSE (ID_Location, Etat_retour, ID_Figuration)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev') and Date_heure = '2025-03-03 14:30:00'),
    'bon',
    (select ID_Figuration from FIGURATION where ID_Fictif = (select ID_Fictif from FICTIF where Nom = 'Sonic'))
);
insert into COMPOSE (ID_Location, Etat_retour, ID_Figuration)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev') and Date_heure = '2025-05-05 09:00:00'),
    'bon',
    (select ID_Figuration from FIGURATION where ID_Animal = (select ID_Animal from ANIMAL where Nom = 'Éléphant d Afrique'))
);
insert into COMPOSE (ID_Location, Etat_retour, ID_Figuration)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'john.doe@test.dev') and Date_heure = '2024-08-07 16:00:00'),
    'bon',
    (select ID_Figuration from FIGURATION where ID_Celebrite = (select ID_Celebrite from CELEBRITE where Nom = 'Hanks'))
);

insert into FACTURE (ID_Location, Adresse_facturation, ID_Adresse, ID_Client)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev') and Date_heure = '2025-03-03 14:30:00'),
    (select ID_Adresse from ADRESSE where Localite = 'Liège'),
    (select ID_Adresse from ADRESSE where Localite = 'Liège'),
    (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev')
);
insert into FACTURE (ID_Location, Adresse_facturation, ID_Adresse, ID_Client)
values (
    (select ID_Location from LOCATION where ID_Client = (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev') and Date_heure = '2025-05-05 09:00:00'),
    (select ID_Adresse from ADRESSE where Localite = 'Liège'),
    (select ID_Adresse from ADRESSE where Localite = 'Liège'),
    (select ID_Client from CLIENT where Mail = 'martin.dupont@test.dev')
);
