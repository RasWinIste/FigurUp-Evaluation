--
-- VIEWS
--

-- To facilitate address usage
CREATE VIEW ADRESSE_VIEW as (
    SELECT a.ID_Adresse, concat(a.Rue, ' ', a.Numero, ', ', a.Code_postal, ' ', a.Localite, ', ', a.Pays) as Libel
    FROM ADRESSE a
);

-- To migrate from a French based database to an English one
CREATE VIEW CUSTOMER AS (
    SELECT ID_Client as ID_Customer, Mail, Mot_de_passe as Password, ID_Adresse as ID_Address, PROFESSIONNEL as Business, PRIVE as Private
    FROM CLIENT
);

CREATE VIEW CLIENT_PAR_PAYS as (
    SELECT count(*) as NOMBRE_CLIENT, adr.Pays as PAYS
    FROM ADRESSE adr
    JOIN CLIENT C on adr.ID_Adresse = C.ID_Adresse
    GROUP BY adr.Pays
);

CREATE VIEW DATE_MAINTENANCE_ASC as (
    SELECT a.Date_prochain_entretien, a.Niveau_batterie, a.ID_Figuration
    FROM ANIMATRONIQUE a
    ORDER BY a.Date_prochain_entretien
);

CREATE VIEW FIG_NEED_MAINTENANCE as (
    SELECT f.ID_Figuration, st.Libelle, f.TYPE
    FROM FIGURATION f
    JOIN STATUT st ON f.ID_Statut = st.ID_Statut
    WHERE st.Libelle = 'Maintenance' or st.Libelle = 'Batterie_faible'
);

CREATE VIEW BATTERY_LEVEL_ASC as (
    SELECT a.Niveau_batterie, a.ID_Figuration
    FROM ANIMATRONIQUE a
    ORDER BY a.Niveau_batterie
);

CREATE VIEW LOCATION_RAPPORT AS
SELECT
    l.ID_Location,
    l.Date_heure,
    l.Duree,
    COUNT(c.ID_Figuration) AS Nbr_figure,
    SUM(CAST(f.Tarif_heure AS DECIMAL(10,2)) * CAST(l.Duree AS DECIMAL(10,2))) AS Total
FROM LOCATION l
JOIN COMPOSE c ON c.ID_Location = l.ID_Location
JOIN FIGURATION f ON f.ID_Figuration = c.ID_Figuration
GROUP BY l.ID_Location, l.Date_heure, l.Duree;

CREATE VIEW RAPPORT_ANNUEL_COMPTABILITE AS
(
    SELECT COALESCE(l.Annee, e.Annee)                           AS Annee,
           COALESCE(e.TotalCout, 0)                             AS Depenses,
           COALESCE(l.TotalGagne, 0)                            AS Gains,
           COALESCE(l.TotalGagne, 0) - COALESCE(e.TotalCout, 0) AS Benefice
    FROM (
        SELECT YEAR(Date_heure) AS Annee, SUM(Total) AS TotalGagne
        FROM LOCATION_RAPPORT
        GROUP BY YEAR(Date_heure)
    ) l
    LEFT JOIN (
        SELECT YEAR(Date_heure) AS Annee, SUM(Cout) AS TotalCout
        FROM ENTRETIEN
        GROUP BY YEAR(Date_heure)
    ) e ON l.Annee = e.Annee

    UNION

    SELECT COALESCE(l.Annee, e.Annee)                           AS Annee,
           COALESCE(e.TotalCout, 0)                             AS Depenses,
           COALESCE(l.TotalGagne, 0)                            AS Gains,
           COALESCE(l.TotalGagne, 0) - COALESCE(e.TotalCout, 0) AS Benefice
    FROM (
        SELECT YEAR(Date_heure) AS Annee, SUM(Cout) AS TotalCout
        FROM ENTRETIEN
        GROUP BY YEAR(Date_heure)
    ) e
    LEFT JOIN (
        SELECT YEAR(Date_heure) AS Annee, SUM(Total) AS TotalGagne
        FROM LOCATION_RAPPORT
        GROUP BY YEAR(Date_heure)
    ) l ON l.Annee = e.Annee
);

CREATE OR REPLACE VIEW RAPPORT_MENSUEL_COMPTABILITE AS
SELECT
    annee_mois.Annee,
    annee_mois.Mois,
    COALESCE(loc.TotalGagne, 0) AS Gains,
    COALESCE(ent.TotalCout, 0) AS Depenses,
    COALESCE(loc.TotalGagne, 0) - COALESCE(ent.TotalCout, 0) AS Benefice
FROM (
    SELECT DISTINCT
        YEAR(Date_heure) AS Annee,
        MONTH(Date_heure) AS Mois
    FROM LOCATION_RAPPORT
    UNION
    SELECT DISTINCT
        YEAR(Date_heure) AS Annee,
        MONTH(Date_heure) AS Mois
    FROM ENTRETIEN
) annee_mois
LEFT JOIN (
    SELECT
        YEAR(Date_heure) AS Annee,
        MONTH(Date_heure) AS Mois,
        SUM(Total) AS TotalGagne
    FROM LOCATION_RAPPORT
    GROUP BY YEAR(Date_heure), MONTH(Date_heure)
) loc ON loc.Annee = annee_mois.Annee AND loc.Mois = annee_mois.Mois
LEFT JOIN (
    SELECT
        YEAR(Date_heure) AS Annee,
        MONTH(Date_heure) AS Mois,
        SUM(Cout) AS TotalCout
    FROM ENTRETIEN
    GROUP BY YEAR(Date_heure), MONTH(Date_heure)
) ent ON ent.Annee = annee_mois.Annee AND ent.Mois = annee_mois.Mois
ORDER BY annee_mois.Annee, annee_mois.Mois;

--
-- CLIENT IS-A VIEW
--
CREATE VIEW CLIENT_ASC AS (
    SELECT c.ID_Client, av.Libel as Adresse, c.Mail, pri.Nom, pri.Prenom, pri.Telephone, pro.Nom_entreprise, pro.TVA, pro.Contact_Nom, pro.Contact_Prenom, pro.Contact_Telephone
    FROM CLIENT c
    JOIN ADRESSE_VIEW av on c.ID_Adresse = av.ID_Adresse

    LEFT JOIN PRIVE pri on c.ID_Client = pri.ID_Client
    LEFT JOIN PROFESSIONNEL pro on c.ID_Client = pro.ID_Client
);

CREATE VIEW CLIENT_PRIVE AS (
    SELECT c.ID_Client, p.Nom, p.Prenom, c.Mail, p.Telephone, av.Libel as Adresse
    FROM CLIENT c
    JOIN ADRESSE_VIEW av on c.ID_Adresse = av.ID_Adresse
    JOIN PRIVE p on c.ID_Client = p.ID_Client
);

CREATE VIEW CLIENT_PRO AS (
    SELECT c.ID_Client, p.Nom_entreprise, p.TVA, p.Contact_Nom, p.Contact_Prenom, c.Mail, p.Contact_Telephone, av.Libel as Adresse
    FROM CLIENT c
    JOIN ADRESSE_VIEW av on c.ID_Adresse = av.ID_Adresse
    JOIN PROFESSIONNEL p on c.ID_Client = p.ID_Client
);

--
-- FIGURATION IS-A VIEW
--
CREATE VIEW FIGURATION_ASC as (
    SELECT f.ID_Figuration, f.Caution, f.Taille, f.Tarif_heure, f.ANIMATRONIQUE, f.STATIQUE, a.Date_prochain_entretien, a.Niveau_batterie
    FROM FIGURATION f

    LEFT JOIN ANIMATRONIQUE a on a.ID_Figuration = f.ID_Figuration
    LEFT JOIN STATIQUE s on f.ID_Figuration = s.ID_Figuration
);

CREATE VIEW STATIQUE_FIG as (
    SELECT f.ID_Figuration, f.Caution, f.Taille, f.Tarif_heure
    FROM FIGURATION f
    JOIN STATIQUE s on s.ID_Figuration = f.ID_Figuration
);

CREATE VIEW ANIMATRONIQUE_FIG as (
    SELECT f.ID_Figuration, f.Caution, f.Taille, f.Tarif_heure, a.Date_prochain_entretien, a.Niveau_batterie
    FROM FIGURATION f
    JOIN ANIMATRONIQUE a on a.ID_Figuration = f.ID_Figuration
);

--
-- CREDENTIALS
--
CREATE ROLE 'technician', 'sale', 'accountant', 'admin';

GRANT ALL ON FigurUp.* TO 'admin';

-- SALE --
GRANT SELECT ON CLIENT_ASC TO 'sale';
GRANT SELECT ON STATIQUE_FIG TO 'sale';
GRANT SELECT ON ANIMATRONIQUE_FIG TO 'sale';
GRANT ALL ON ANIMAL TO 'sale';
GRANT ALL ON FICTIF TO 'sale';
GRANT ALL ON CELEBRITE TO 'sale';
GRANT SELECT ON STATUT TO 'sale';
GRANT SELECT ON TIERS TO 'sale';
GRANT ALL ON FIGURATION to 'sale';
GRANT INSERT, UPDATE, DELETE ON STATIQUE to 'sale';
GRANT INSERT, UPDATE, DELETE ON ANIMATRONIQUE to 'sale';

-- ACCOUNTANT --
GRANT SELECT ON CLIENT_PAR_PAYS TO 'accountant';
GRANT SELECT ON RAPPORT_ANNUEL_COMPTABILITE to 'accountant';
GRANT SELECT ON RAPPORT_MENSUEL_COMPTABILITE to 'accountant';

-- TECHNICIAN --
GRANT SELECT ON ANIMATRONIQUE_FIG TO 'technician';
GRANT SELECT ON STATIQUE_FIG TO 'technician';
GRANT SELECT ON TECHNICIEN TO 'technician';
GRANT SELECT, UPDATE ON COMPOSE TO 'technician';
GRANT SELECT ON DATE_MAINTENANCE_ASC TO 'technician';
GRANT SELECT ON BATTERY_LEVEL_ASC TO 'technician';
GRANT SELECT ON FIG_NEED_MAINTENANCE TO 'technician';
GRANT ALL ON ENTRETIEN TO 'technician';

CREATE USER 'bob' IDENTIFIED BY 'azerty123';
GRANT 'technician' TO 'bob';
SET DEFAULT ROLE 'technician' TO 'bob';

CREATE USER 'william' IDENTIFIED BY 'azerty123';
GRANT 'sale' TO 'william';
SET DEFAULT ROLE 'sale' TO 'william';

CREATE USER 'catherine' IDENTIFIED BY 'azerty123';
GRANT 'accountant' TO 'catherine';
SET DEFAULT ROLE 'accountant' TO 'catherine';

CREATE USER 'mark' IDENTIFIED BY 'azerty123';
GRANT 'admin' TO 'mark';
SET DEFAULT ROLE 'admin' TO 'mark';

--
-- HANDLING OF THE USER IS-A
--

revoke update (STATIQUE, ANIMATRONIQUE, TYPE) on FIGURATION from public;
revoke update (ID_Figuration) on STATIQUE from public;
revoke update (ID_Figuration) on ANIMATRONIQUE from public;

-- Statique
create trigger TRG_STATIC_SUPP_ISA_FIG
after delete on STATIQUE
for each row
begin
    update FIGURATION
    set STATIQUE = null, TYPE = ''
    where ID_Figuration = old.ID_Figuration;
end;


CREATE TRIGGER TRG_STATIC_INSERT_ISA_FIG
BEFORE INSERT ON STATIQUE
FOR EACH ROW
BEGIN
    DECLARE fig_count INT DEFAULT 0;

    SELECT COUNT(*) INTO fig_count
    FROM FIGURATION
    WHERE ID_Figuration = NEW.ID_Figuration
      AND (STATIQUE IS NOT NULL OR ANIMATRONIQUE IS NOT NULL);

    IF fig_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This figuration already has a subtype (STATIQUE or ANIMATRONIQUE).';
    END IF;

    UPDATE FIGURATION
    SET STATIQUE = NEW.ID_Figuration, TYPE = 'S'
    WHERE ID_Figuration = NEW.ID_Figuration;
END;

-- Animatronique

create trigger TRG_ANIMA_SUPP_ISA_FIG
after delete on ANIMATRONIQUE
for each row
begin
    update FIGURATION
    set ANIMATRONIQUE = null, TYPE = ''
    where ID_Figuration = old.ID_Figuration;
end;

CREATE TRIGGER TRG_ANIMA_INSERT_ISA_FIG
BEFORE INSERT ON ANIMATRONIQUE
FOR EACH ROW
BEGIN
    DECLARE fig_count INT DEFAULT 0;

    SELECT COUNT(*) INTO fig_count
    FROM FIGURATION
    WHERE ID_Figuration = NEW.ID_Figuration
      AND (STATIQUE IS NOT NULL OR ANIMATRONIQUE IS NOT NULL);

    IF fig_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This figuration already has a subtype (STATIQUE or ANIMATRONIQUE).';
    END IF;

    UPDATE FIGURATION
    SET ANIMATRONIQUE = NEW.ID_Figuration, TYPE = 'A'
    WHERE ID_Figuration = NEW.ID_Figuration;
END;

--
-- TRIGGERS
--

-- Location without battery
CREATE TRIGGER TRG_LOCATION_WITHOUT_BATTERY
BEFORE INSERT ON COMPOSE
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM ANIMATRONIQUE WHERE ID_Figuration = NEW.ID_Figuration AND Niveau_batterie < 50) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This animatronic has not enough battery.';
        DELETE FROM COMPOSE WHERE ID_Location = NEW.ID_Location;
        DELETE FROM LOCATION WHERE ID_Location = NEW.ID_Location;
    END IF;
END;

-- Location after maintenance limit
CREATE TRIGGER TRG_LOCATION_AFTER_MAINTENANCE_LIMIT
BEFORE INSERT ON COMPOSE
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM ANIMATRONIQUE WHERE ID_Figuration = NEW.ID_Figuration AND Date_prochain_entretien < NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This animatronic must undergo maintenance first.';
        DELETE FROM COMPOSE WHERE ID_Location = NEW.ID_Location;
        DELETE FROM LOCATION WHERE ID_Location = NEW.ID_Location;
    END IF;
END;

-- DOUBLE RENTAL
CREATE TRIGGER TRG_NO_DOUBLE_RENTAL
BEFORE INSERT ON COMPOSE
FOR EACH ROW
BEGIN
   IF EXISTS (
        SELECT 1
        FROM COMPOSE c
        JOIN LOCATION l1 ON l1.ID_Location = c.ID_Location
        JOIN LOCATION l2 ON l2.ID_Location = NEW.ID_Location
        WHERE c.ID_Figuration = NEW.ID_Figuration
          AND (
              l1.Date_heure < DATE_ADD(l2.Date_heure, INTERVAL l2.Duree HOUR)
              AND l2.Date_heure < DATE_ADD(l1.Date_heure, INTERVAL l1.Duree HOUR)
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This figuration is already rented for a conflicting time.';
   END IF;
END;

-- DELETE CLIENT WITH LOCATION
CREATE TRIGGER TRG_DELETE_COMPOSE
BEFORE DELETE ON CLIENT
FOR EACH ROW
BEGIN
    UPDATE LOCATION SET ID_Client = null WHERE ID_Client = OLD.ID_Client;
END;

CREATE TRIGGER TRG_DELETE_BILL
BEFORE DELETE ON PROFESSIONNEL
FOR EACH ROW
BEGIN
    UPDATE FACTURE SET ID_Client = null WHERE ID_Client = OLD.ID_Client;
END;

-- UPDATE STATUS AFTER RETURN
CREATE TRIGGER TGR_UPDATE_STATUS
AFTER UPDATE ON COMPOSE
FOR EACH ROW
BEGIN
   IF NEW.Etat_retour = 'bon' THEN
       UPDATE FIGURATION
       SET ID_Statut = (SELECT ID_Statut FROM STATUT WHERE Libelle = 'Disponible')
       WHERE ID_Figuration = NEW.ID_Figuration;
   END IF;
   IF NEW.Etat_retour = 'maintenance' THEN
       UPDATE FIGURATION
       SET ID_Statut = (SELECT ID_Statut FROM STATUT WHERE Libelle = 'Maintenance')
       WHERE ID_Figuration = NEW.ID_Figuration;
   END IF;
END;

-- UPDATE STATUS AFTER RETURN
CREATE TRIGGER TGR_UPDATE_DATE_MAINTENANCE
AFTER UPDATE ON FIGURATION
FOR EACH ROW
BEGIN
   IF NEW.ID_Statut = (SELECT ID_Statut FROM STATUT WHERE Libelle = 'Maintenance') and EXISTS(SELECT * FROM ANIMATRONIQUE WHERE ID_Figuration = NEW.ID_Figuration) THEN
       UPDATE ANIMATRONIQUE
       SET Date_prochain_entretien = NOW()
       WHERE ID_Figuration = NEW.ID_Figuration;
   END IF;
END;

--
--  PROCEDURE
--

CREATE PROCEDURE update_figure_status()
BEGIN
    DECLARE statutLoue CHAR(36);
    DECLARE statutDisponible CHAR(36);

    SELECT ID_Statut INTO statutLoue FROM STATUT WHERE Libelle = 'Loué';
    SELECT ID_Statut INTO statutDisponible FROM STATUT WHERE Libelle = 'Disponible';

    UPDATE FIGURATION
    SET ID_Statut = statutDisponible
    WHERE ID_Statut = statutLoue;

    UPDATE FIGURATION
    SET ID_Statut = statutLoue
    WHERE ID_Figuration IN (
        SELECT c.ID_Figuration
        FROM COMPOSE c
        JOIN LOCATION l ON l.ID_Location = c.ID_Location
        WHERE NOW() BETWEEN l.Date_heure AND DATE_ADD(l.Date_heure, INTERVAL l.Duree HOUR)
    );
END;


-- Batterie faible trigger
CREATE TRIGGER BATTERY_LEVEL_STATUS
AFTER UPDATE ON ANIMATRONIQUE
FOR EACH ROW
BEGIN
    DECLARE statutDisponible CHAR(36);
    DECLARE statutBatterie CHAR(36);
    DECLARE figStatus CHAR(36);

    SELECT ID_Statut INTO statutDisponible FROM STATUT WHERE Libelle = 'Disponible';
    SELECT ID_Statut INTO statutBatterie FROM STATUT WHERE Libelle = 'Batterie_faible';
    SELECT f.ID_Statut INTO figStatus FROM FIGURATION f WHERE f.ID_Figuration = NEW.ID_Figuration;

   IF (new.Niveau_batterie < 50 and figStatus = statutDisponible) THEN
        UPDATE FIGURATION
        SET ID_Statut = statutBatterie
        WHERE ID_Figuration = new.ID_Figuration;
   ELSEIF (new.Niveau_batterie >= 50 and figStatus = statutBatterie) THEN
        UPDATE FIGURATION
        SET ID_Statut = statutDisponible
        WHERE ID_Figuration = new.ID_Figuration;
   END IF;
END;