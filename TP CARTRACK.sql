CREATE TABLE ClientCT (
    idclient INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    adresse VARCHAR(100) NOT NULL,
    tel VARCHAR(20) NOT NULL
);

CREATE TABLE Voiture (
    plaque VARCHAR(15) PRIMARY KEY,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    couleur VARCHAR(30) NOT NULL,
    date_immatriculation DATE NOT NULL,
    idclient INT NOT NULL,
    FOREIGN KEY (idclient) REFERENCES ClientCT(idclient)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Systeme (
    code INT PRIMARY KEY,
    plaque VARCHAR(15) NOT NULL,
    FOREIGN KEY (plaque) REFERENCES Voiture(plaque)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Etat (
    idetat INT PRIMARY KEY,
    code_systeme INT NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    alarme VARCHAR(10) NOT NULL,
    porte VARCHAR(15) NOT NULL,
    FOREIGN KEY (code_systeme) REFERENCES Systeme(code)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PartenaireCT (
    idpartenaire INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    adresse VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL
);

CREATE TABLE Installation (
    idinsta INT PRIMARY KEY,
    idpartenaire INT NOT NULL,
    code_systeme INT NOT NULL,
    date_install DATE NOT NULL,
    heure_install TIME NOT NULL,
    FOREIGN KEY (idpartenaire) REFERENCES PartenaireCT(idpartenaire)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (code_systeme) REFERENCES Systeme(code)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Client (
    code INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    codeAdresse INT NOT NULL,
    telephone VARCHAR(20) NOT NULL
);

CREATE TABLE Categorie (
    code INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL
);

CREATE TABLE Produit (
    code INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    description TEXT,
    codeCategorie INT NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (codeCategorie) REFERENCES Categorie(code)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Stock (
    date DATE NOT NULL,
    codeProduit INT NOT NULL,
    unites INT NOT NULL,
    PRIMARY KEY (date, codeProduit),
    FOREIGN KEY (codeProduit) REFERENCES Produit(code)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Commande (
    code INT PRIMARY KEY,
    date DATE NOT NULL,
    codeClient INT NOT NULL,
    codeProduit INT NOT NULL,
    quantite INT NOT NULL,
    FOREIGN KEY (codeClient) REFERENCES Client(code)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codeProduit) REFERENCES Produit(code)
        ON DELETE CASCADE ON UPDATE CASCADE
);


INSERT INTO Client VALUES (101,'Ghodbani','Syrine',1,'0601020304');
INSERT INTO Client VALUES (102,'Pascal','Marie',2,'0605060708');

INSERT INTO Categorie VALUES (1,'Livres');
INSERT INTO Categorie VALUES (2,'Electroménager');

INSERT INTO Produit VALUES (201,'Ventilateur','Ventilateur sur pied',2,49.99);
INSERT INTO Produit VALUES (202,'Harry Potter','Livre fantastique',1,19.99);

INSERT INTO Stock VALUES ('2025-11-29',201,50);
INSERT INTO Stock VALUES ('2025-11-29',202,30);

INSERT INTO Commande VALUES (301,'2025-11-28',101,201,2);
INSERT INTO Commande VALUES (302,'2025-11-28',102,202,1);

SELECT SUM(Stock.unites)  AS TotalUnites
FROM Stock 
INNER JOIN Produit ON Stock.codeProduit = Produit.code 
WHERE Produit.nom = 'Ventilateur';

SELECT COUNT(*) 
FROM Commande 
INNER JOIN Client ON Commande.codeClient = Client.code 
INNER JOIN Produit ON Commande.codeProduit = Produit.code 
INNER JOIN Categorie ON Produit.codeCategorie = Categorie.code 
WHERE Client.nom = 'Pascal' 
  AND Client.prenom = 'Marie' 
  AND Categorie.nom = 'Livres';

SELECT codeClient, SUM(quantite) AS TotalQuantite
FROM Commande
WHERE date >= '2013-11-01' AND date <= '2013-11-30'
GROUP BY codeClient
ORDER BY TotalQuantite DESC;

SELECT Produit.nom
FROM Produit
LEFT JOIN Commande ON Produit.code = Commande.codeProduit
WHERE Commande.codeProduit IS NULL;

SELECT Produit.nom, Produit.prix, Categorie.nom
FROM Produit
INNER JOIN Categorie ON Produit.codeCategorie = Categorie.code
WHERE Produit.prix > (
    SELECT AVG(Produit.prix)
    FROM Produit
    WHERE Produit.codeCategorie = Produit.codeCategorie
);
