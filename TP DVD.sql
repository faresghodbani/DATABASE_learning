CREATE TABLE Societe (
    numS INT PRIMARY KEY,
    nomS VARCHAR(50) NOT NULL,
    rueS VARCHAR(50) NOT NULL,
    villeS VARCHAR(50) NOT NULL,
    directeurS VARCHAR(50) NOT NULL,
    numRueS INT NOT NULL
);

CREATE TABLE Dvd (
    numD INT PRIMARY KEY,
    titreD VARCHAR(100) NOT NULL,
    auteurD VARCHAR(100) NOT NULL,
    anneeD INT NOT NULL,
    categorieD VARCHAR(50) NOT NULL,
    dateAchatD DATE NOT NULL,
    nombreD INT NOT NULL,
    societeD INT NOT NULL,
    FOREIGN KEY (societeD) REFERENCES Societe(numS)
);

CREATE TABLE Acteur (
    numA INT PRIMARY KEY,
    nomA VARCHAR(50) NOT NULL,
    prenomA VARCHAR(50) NOT NULL,
    ageA INT NOT NULL,
    sexeA CHAR(1) NOT NULL
);

CREATE TABLE Casting (
    dvdC INT NOT NULL,
    acteurC INT NOT NULL,
    roleC VARCHAR(100) NOT NULL,
    PRIMARY KEY (dvdC, acteurC),
    FOREIGN KEY (dvdC) REFERENCES Dvd(numD),
    FOREIGN KEY (acteurC) REFERENCES Acteur(numA)
);

CREATE TABLE Emprunt (
    dvdE INT NOT NULL,
    dateE DATE NOT NULL,
    clientE INT NOT NULL,
    dureeE INT NOT NULL,
    PRIMARY KEY (dvdE, dateE, clientE),
    FOREIGN KEY (dvdE) REFERENCES Dvd(numD)
);

INSERT INTO Societe VALUES (1, 'DVDStore', 'Rue des Lilas', 'Nice', 'Martin Dupont');
INSERT INTO Societe VALUES (2, 'VideoPlus', 'Avenue de la Liberté', 'Cannes', 'Sophie Durand');
INSERT INTO Societe VALUES (3, 'DVDStore', 'Boulevard Saint-Germain', 'Paris', 'Jean Moreau');

INSERT INTO Dvd VALUES (101, 'Avengers', 'Joss Whedon', 2012, 'Action', '2015-06-01', 10, 1);
INSERT INTO Dvd VALUES (102, 'Inception', 'Christopher Nolan', 2010, 'Science-Fiction', '2016-01-15', 5, 1);
INSERT INTO Dvd VALUES (103, 'Le Fabuleux Destin d''Amélie Poulain', 'Jean-Pierre Jeunet', 2001, 'Comédie', '2014-09-20', 8, 2);

INSERT INTO Acteur VALUES (201, 'Downey', 'Robert', 55, 'M');
INSERT INTO Acteur VALUES (202, 'Pitt', 'Brad', 60, 'M');
INSERT INTO Acteur VALUES (203, 'Dolan', 'Xavier', 32, 'M');

INSERT INTO Casting VALUES (101, 201, 'Iron Man');
INSERT INTO Casting VALUES (102, 202, 'Dom Cobb');
INSERT INTO Casting VALUES (103, 203, 'Amélie (voix)');

INSERT INTO Emprunt VALUES (101, '2025-11-01', 301, 7);
INSERT INTO Emprunt VALUES (102, '2025-11-03', 302, 5);
INSERT INTO Emprunt VALUES (103, '2025-11-05', 303, 3);

SELECT Dvd.titreD
FROM Dvd
INNER JOIN Societe ON Dvd.societeD = Societe.numS
WHERE Societe.nomS = 'DVDStore';

SELECT Dvd.titreD, Acteur.nomA, Acteur.prenomA
FROM Dvd
INNER JOIN Societe ON Dvd.societeD = Societe.numS
INNER JOIN Casting ON Dvd.numD = Casting.dvdC
INNER JOIN Acteur ON Casting.acteurC = Acteur.numA
WHERE Societe.nomS = 'DVDStore';

SELECT Dvd.titreD, Acteur.nomA, Acteur.prenomA
FROM Dvd
INNER JOIN Casting ON Dvd.numD = Casting.dvdC
INNER JOIN Acteur ON Casting.acteurC = Acteur.numA;

SELECT DISTINCT Emprunt.clientE
FROM Dvd
INNER JOIN Emprunt ON Dvd.numD = Emprunt.dvdE
INNER JOIN Casting ON Dvd.numD = Casting.dvdC
INNER JOIN Acteur ON Casting.acteurC = Acteur.numA
WHERE Acteur.prenomA = 'xavier';
