CREATE DATABASE IF NOT EXISTS google_calendar;
USE google_calendar;

CREATE TABLE Compte(
    email VARCHAR(50) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    PRIMARY KEY (email)
);

CREATE TABLE Profil(
    email VARCHAR(50) NOT NULL,
    profession VARCHAR(50),
    introduction TEXT,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Compte(email)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Agenda(
    email VARCHAR(50) NOT NULL,
    nom_agenda VARCHAR(50) NOT NULL,
    description TEXT,
    lieu VARCHAR(50),
    confidentialite ENUM('public','prive','restreint') DEFAULT 'prive',
    PRIMARY KEY (email, nom_agenda),
    FOREIGN KEY (email) REFERENCES Compte(email)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Experience(
    email VARCHAR(50) NOT NULL,
    date_debut DATE NOT NULL,
    duree INT NOT NULL,
    entreprise VARCHAR(50) NOT NULL,
    fonction VARCHAR(50) NOT NULL,
    PRIMARY KEY (email, date_debut),
    FOREIGN KEY (email) REFERENCES Compte(email)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Evenement(
    id INT NOT NULL AUTO_INCREMENT,
    email VARCHAR(50) NOT NULL,
    nom_agenda VARCHAR(50) NOT NULL,
    date_debut DATE NOT NULL,
    heure_debut TIME NOT NULL,
    duree INT NOT NULL,
    description TEXT,
    lieu VARCHAR(50),
    confidentialite ENUM('defaut','public','prive') DEFAULT 'defaut',
    PRIMARY KEY (id),
    FOREIGN KEY (email, nom_agenda) REFERENCES Agenda(email, nom_agenda)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Est_partage(
    nom_agenda VARCHAR(50) NOT NULL,
    email_proprietaire VARCHAR(50) NOT NULL,
    email_invite VARCHAR(50) NOT NULL,
    PRIMARY KEY(nom_agenda, email_proprietaire, email_invite),
    FOREIGN KEY (email_proprietaire, nom_agenda) REFERENCES Agenda(email, nom_agenda)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (email_invite) REFERENCES Compte(email)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Est_invite(
    id_evenement INT NOT NULL,
    email_invite VARCHAR(50) NOT NULL,
    PRIMARY KEY(id_evenement, email_invite),
    FOREIGN KEY (id_evenement) REFERENCES Evenement(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO `Compte` VALUES('eric.valade@unice.fr' ,'Valade', 'Eric');
INSERT INTO `Compte` VALUES('fares.ghodbani@unice.fr' ,'Ghodbani', 'Fares');

INSERT INTO `Profil` VALUES('eric.valade@unice.fr' ,'ingenieur', 'coucou');
INSERT INTO `Profil` VALUES('fares.ghodbani@unice.fr' ,'etudianr', 'salut');

INSERT INTO `Agenda` VALUES('eric.valade@unice.fr' ,'ergenda', 'agenda de eric' , 'Nice' , 'public');
INSERT INTO `Agenda` VALUES('fares.ghodbani@unice.fr' ,'fargenda', 'agenda de fares' , '' , 'restreint' );

INSERT INTO `Experience` VALUES('eric.valade@unice.fr' ,'14/02/2025', 6 , 'Amazon' , 'cadre');
INSERT INTO `Experience` VALUES('fares.ghodbani@unice.fr' ,'24/01/2025', 14 , 'Unica' , 'etudiant' );

INSERT INTO `Evenement` VALUES(1 ,'eric.valade@unice.fr' ,'ergenda' , '2025-12-19', '14:15:00' , 120 , 'Examen' , 'Nice' , 'public');
INSERT INTO `Evenement` VALUES(2 ,'fares.ghodbani@unice.fr' , 'fargenda' , '2025-10-25', '8:30:00' , 60 , 'controle' , 'defaut');

INSERT INTO `Est_partage` VALUES('ergenda' , 'eric.valade@unice.fr' , 'fares.ghodbani@unice.fr');
INSERT INTO `Est_partage` VALUES('fargenda' , 'fares.ghodbani@unice.fr' , 'eric.valade@unice.fr' );

INSERT INTO `Est_invite` VALUES(1 , 'olivier.baldellon@unice.fr' );

SELECT nom_agenda
FROM Agenda
WHERE lieu IS NULL OR lieu = '';

SELECT *
FROM Evenement
INNER JOIN Est_invite ON Evenement.id = Est_invite.id_evenement
WHERE Est_invite.email_invite IS NOT NULL
  AND Est_invite.email_invite != '';

SELECT entreprise, COUNT(Experience.email) AS nb_ingenieurs
FROM Experience
INNER JOIN Profil ON Experience.email = Profil.email
WHERE Profil.profession = 'ingenieur'
GROUP BY Experience.entreprise;

--version avec EXISTS et NOT EXISTS (Differennce) 
SELECT Agenda.nom_agenda
FROM Agenda
WHERE EXISTS (
    SELECT 1
    FROM Evenement
    WHERE Evenement.email = Agenda.email
      AND Evenement.nom_agenda = Agenda.nom_agenda
      AND Evenement.confidentialite = 'defaut'
)
AND NOT EXISTS (
    SELECT 1
    FROM Evenement
    INNER JOIN Est_invite ON Evenement.id = Est_invite.id_evenement
    WHERE Evenement.email = Agenda.email
      AND Evenement.nom_agenda = Agenda.nom_agenda
      AND Evenement.confidentialite = 'defaut'
);

--version avec left JOIN
SELECT DISTINCT Agenda.nom_agenda
FROM Agenda
LEFT JOIN Evenement 
    ON Agenda.email = Evenement.email 
   AND Agenda.nom_agenda = Evenement.nom_agenda
LEFT JOIN Est_invite 
    ON Evenement.id = Est_invite.id_evenement
WHERE Evenement.confidentialite = 'defaut'
  AND Est_invite.id_evenement IS NULL;

  
SELECT DISTINCT nom
FROM Compte
INNER JOIN Est_partage ON Compte.email = Est_partage.email_proprietaire
WHERE NOT EXISTS (
    SELECT Compte2.email
    FROM Compte AS Compte2
    WHERE Compte2.email != Est_partage.email_proprietaire
      AND NOT EXISTS (
          SELECT 1
          FROM Est_partage
          WHERE Est_partage.email_proprietaire = Compte.email
            AND Est_partage.email_invite = Compte2.email
      )
);

SELECT nom, duree
FROM Compte
INNER JOIN Experience ON Compte.email = Experience.email
INNER JOIN Profil ON Compte.email = Profil.email
WHERE Profil.profession = (
    SELECT profession
    FROM Profil
    WHERE email = 'eric.valade@unice.fr'
)
AND Experience.duree > (
    SELECT MAX(Experience.duree)
    FROM Experience
    INNER JOIN Profil ON Experience.email = Profil.email
    WHERE Profil.email = 'eric.valade@unice.fr'
);

SELECT nom, prenom
FROM Compte
NATURAL JOIN Profil
WHERE profession = 'ingenieur'
  AND NOT EXISTS (
      SELECT *
      FROM Experience
      WHERE Experience.email = Compte.email
        AND duree > 100
  );
