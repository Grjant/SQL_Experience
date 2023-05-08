-- Grant Jacobs
-- A4 CS331e

DROP TABLE LOAN;
DROP TABLE READER;
DROP TABLE PHYSICALCOPY;
DROP TABLE BOOK;

-- 1) Create the relations: BOOK, PHYSICALCOPY, READER and LOAN 
CREATE TABLE BOOK (
    ISBN varchar(20) PRIMARY KEY,
    title varchar(100) NOT NULL,
    authors varchar(100) NOT NULL,
    publisher varchar(100) NOT NULL,
    year int NOT NULL,
    price decimal(10,2) NOT NULL
);

CREATE TABLE PHYSICALCOPY (
    catalogNo serial PRIMARY KEY,
    ISBN varchar(20) REFERENCES BOOK(ISBN) ON DELETE CASCADE,
    location varchar(100) NOT NULL,
    maxDaysLoan int  NOT NULL,
    overdueChargePerDay decimal(10,2)  NOT NULL
);

CREATE TABLE READER (
    userName varchar(20) PRIMARY KEY,
    name varchar(100) NOT NULL,
    address varchar(200) NOT NULL,
    maxNoBooksForLoan int NOT NULL
);

CREATE TABLE LOAN (
    userName varchar(20) REFERENCES READER(userName) ON DELETE CASCADE,
    catalogNo int REFERENCES PHYSICALCOPY(catalogNo) ON DELETE CASCADE,
    dateOut date NOT NULL,
    dateIn date,
    PRIMARY KEY (userName, catalogNo, dateOut)
);

-- 2) Insert a set of tuples (rows) into the relations created in 1).
INSERT INTO BOOK (ISBN, title, authors, publisher, year, price) VALUES 
    ('9780136597075', 'Banana Farm', 'Andrea Hunter', 'Addison', 2020, 27.99),
    ('9780136597678', 'Design Patterns: Elements of Reusable Object-Oriented Software', 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides', 'Addison-Wesley', 1994, 54.99),
    ('9767836597098', 'Bruh Moment', 'Grant Swaggy', 'Cool Publisher 1', 2022, 39.99),
    ('9886687197032', 'Fundamentals of Database', 'Ramez Elmasri', 'Addison-Wesley', 2000, 100.00);

INSERT INTO PHYSICALCOPY (catalogNo, ISBN, location, maxDaysLoan, overdueChargePerDay)VALUES
    (1, '9780136597075', 'A101', 7, 0.50),
    (2, '9780136597075', 'A102', 14, 0.50),
    (3, '9780136597678', 'A201', 14, 0.50),
    (4, '9780136597678', 'B101', 14, 0.50),
    (5, '9767836597098', 'C101', 21, 0.75),
    (6, '9886687197032', 'C221', 27, 0.75);

INSERT INTO READER (userName, name, address, maxNoBooksForLoan)VALUES
    ('gooseegg', 'Goose Egg', '123 Main St, Wildin Pt, USA', 2),
    ('SwaggyP', 'Nick Young', '456 Oak St, Cool Dr, USA', 3),
    ('Gold', 'Goldy Smith', '981 Bruh St, Swag Dr, USA', 4),
    ('grjant', 'Grant Jacobs', '789 Swaggy St, Austin, USA', 5);

INSERT INTO LOAN (userName, catalogNo, dateOut, dateIn)VALUES
    ('gooseegg', 1, '2023-03-01', '2023-03-14'),
    ('SwaggyP', 3, '2023-04-01', NULL),
    ('grjant', 5, '2023-04-02', '2023-04-09'),
    ('Gold', 4, '2023-04-03', NULL);

-- 3) List the title, authors, and price for all the books published by Addison-Wesley in 2000, in alphabetical order with respect to titles.
SELECT title, authors, price
FROM BOOK
WHERE publisher = 'Addison-Wesley' AND year = 2000
ORDER BY title ASC;

-- 4) List the titles of all the books that can be taken on loan for more than three days
SELECT b.title
FROM BOOK b
INNER JOIN PHYSICALCOPY pc ON b.ISBN = pc.ISBN
WHERE pc.maxDaysLoan > 3
GROUP BY b.Title;

-- 5) List how many non-returned books (as in physical copies) does the reader “Goldy Smith” have (hint: a non-returned book has no value for ‘dateIn’).
SELECT COUNT(*)
FROM LOAN l NATURAL JOIN Reader r
WHERE r.name = 'Goldy Smith' AND l.dateIn IS NULL;

-- 6) List the names of all the readers (i.e., values of the "name" attribute) who have non-returned books together with the total number of non-returned books, but only if this total exceeds their quota (‘maxNoBooksForLoan’)
SELECT r.name, COUNT(*) AS numNonReturnedBooks
FROM READER r
    INNER JOIN LOAN l ON r.userName = l.userName
    INNER JOIN PHYSICALCOPY pc ON l.catalogNo = pc.catalogNo
WHERE l.dateIn IS NULL
GROUP BY r.name
HAVING COUNT(*) > r.maxNoBooksForLoan;

-- 7) List the Names of all the readers who loaned a book whose name is “fundamentals of database”
SELECT r.name
FROM READER r
    INNER JOIN LOAN l ON r.userName = l.userName
    INNER JOIN PHYSICALCOPY pc ON l.catalogNo = pc.catalogNo
    INNER JOIN BOOK b ON pc.ISBN = b.ISBN
WHERE b.title = 'fundamentals of database';

-- 8) List all the readers (as name and address) who have books overdue, together with the titles of these books (a book is considered overdue if it was not yet returned and it was on loan for more than the maximum number of days allowed ('maxDaysLoan') . Hint: you can use the function CURRENT_DATE to obtain the current date.
SELECT r.name, r.address, b.title
FROM READER r
    INNER JOIN LOAN l ON r.userName = l.userName
    INNER JOIN PHYSICALCOPY pc ON l.catalogNo = pc.catalogNo
    INNER JOIN BOOK b ON pc.ISBN = b.ISBN
WHERE l.dateIn IS NULL AND CURRENT_DATE > (l.dateOut + pc.maxDaysLoan * INTERVAL '1 DAY');

-- 9) Delete the LOAN relation.
DROP TABLE LOAN;