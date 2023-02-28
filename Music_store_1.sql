CREATE DATABASE IF NOT EXISTS musicdatastore;

USE musicdatastore;
-- ---========================creating table for employee=====================================================================================
CREATE TABLE IF NOT EXISTS employee(
employee_id INT PRIMARY KEY,
last_name varchar(50) NOT NULL,
first_name VARCHAR(50) NOT NULL,
title VARCHAR(50) NOT NULL,
reports_to INT DEFAULT NULL,
levels VARCHAR(20) NOT NULL,
birthdate varchar(30),
hire_date varchar(30),
address VARCHAR(50) NOT NULL,
city VARCHAR(50) DEFAULT NULL,
state VARCHAR(50) DEFAULT NULL,
country VARCHAR(50) NOT NULL,
postal_code VARCHAR(15) NOT NULL,
phone VARCHAR(20) NOT NULL,
fax VARCHAR(25) NOT NULL,
email VARCHAR(100) NOT NULL);


DESC employee;
-- Alter Table employee DROP FOREIGN KEY reports_to;

Alter Table employee DROP CONSTRAINT fk_employee_reports_to;

-- ================================creating table for customer ===============================================================================


CREATE TABLE IF NOT EXISTS customer(
customer_id INT NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
company VARCHAR(50) DEFAULT NULL,
address VARCHAR(100) NOT NULL,
city VARCHAR(30) NOT NULL,
state VARCHAR(20) DEFAULT NULL,
country VARCHAR(30) NOT NULL,
postal_code VARCHAR(25) DEFAULT NULL,
phone VARCHAR(30) DEFAULT NULL,
fax VARCHAR(50) DEFAULT NULL,
email VARCHAR(100) NOT NULL,
support_rep_id INT NOT NULL,
PRIMARY KEY (customer_id),
CONSTRAINT fk_customer_support_rep_id
FOREIGN KEY (support_rep_id)
REFERENCES employee (employee_id) ON UPDATE CASCADE ON DELETE CASCADE);

drop table customer;
DESC customer;
--- ======================================== creating table for invoice ======================================================================
CREATE TABLE invoice(
invoice_id INT NOT NULL PRIMARY KEY,
customer_id INT NOT NULL,
invoice_date varchar(30) NOT NULL,
billing_address varchar(100) NOT NULL,
billing_city VARCHAR(30) DEFAULT NULL,
billing_state varchar(30) DEFAULT NULL,
billing_country varchar(30) NOT NULL,
billing_postal_code varchar(30) DEFAULT NULL,
total DECIMAL(4,2),
CONSTRAINT fk_invoice_customer_id
FOREIGN KEY (customer_id)
REFERENCES customer (customer_id) ON DELETE CASCADE);

DESC invoice;

select count(*) from invoice;

-- ====================================================== creating table for artist ==========================================================

CREATE TABLE IF NOT EXISTS artist(
artist_id INT NOT NULL PRIMARY KEY,
name VARCHAR(150) NOT NULL);

desc artist;

-- ===================================================creating table fro album================================================================
CREATE TABLE IF NOT EXISTS album(        
album_id INT NOT NULL PRIMARY KEY,
title VARCHAR(100) NOT NULL,
artist_id INT NOT NULL,
CONSTRAINT fk_album_artist_id
FOREIGN KEY (artist_id)
REFERENCES artist (artist_id) ON DELETE CASCADE);
desc album; 
select count(*) from album;

-- ==============================================creting table for genre======================================================================
CREATE TABLE IF NOT EXISTS genre(
genre_id INT NOT NULL PRIMARY KEY,
name varchar(100));
DESC genre;
select count(*) from genre;

-- =============================================creating table for media_type=================================================================
CREATE TABLE IF NOT EXISTS media_type(
media_type_id INT NOT NULL PRIMARY KEY,
name VARCHAR(100) NOT NULL);
desc media_type;
select * from media_type;
-- ============================================= creting table for track ====================================================================
CREATE TABLE IF NOT EXISTS track(
track_id INT NOT NULL PRIMARY KEY,
name VARCHAR(200),
album_id INT ,
media_type_id INT,
genre_id INT,
composer VARCHAR(200) DEFAULT NULL,
milliseconds INT,
bytes INT,
unit_price DECIMAL(3,2),
CONSTRAINT fk_track_media_type_id FOREIGN KEY (media_type_id) REFERENCES media_type (media_type_id) ON DELETE CASCADE,
CONSTRAINT fk_track_genre_id FOREIGN KEY (genre_id) REFERENCES genre (genre_id)ON DELETE CASCADE,
CONSTRAINT fk_track_album_id FOREIGN KEY (album_id) REFERENCES album (album_id)ON DELETE CASCADE);
desc track;
-- ===========================================creating table for invoice_line=================================================================
CREATE TABLE IF NOT EXISTS invoice_line(
invoice_line_id INT NOT NULL PRIMARY KEY,
invoice_id INT NOT NULL,
track_id INT NOT NULL,
unit_price DECIMAL(3,2),
quantity INT NOT NULL,
CONSTRAINT fk_invoice_line_invoice_id FOREIGN KEY (invoice_id) REFERENCES invoice (invoice_id)ON DELETE CASCADE,
CONSTRAINT fk_invoice_line_track_id FOREIGN KEY (track_id) REFERENCES track (track_id)ON DELETE CASCADE);

desc invoice_line;
SELECT * from invoice_line;
-- =============================================== creating table for palaylistt==============================================================
CREATE TABLE IF NOT EXISTS playlist(
playlist INT NOT NULL PRIMARY KEY,
name varchar(100) NOT NULL);
desc playlist;
select * from playlist;
-- ============================================== creating table for playlist_track ==========================================================
CREATE TABLE IF NOT EXISTS playlist_track(
playlist_id INT NOT NULL,
track_id INT NOT NULL,
CONSTRAINT fk_playlist_track_playlist_id FOREIGN KEY (playlist_id) REFERENCES playlist (playlist)ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT fk_playlist_track_track_id FOREIGN KEY (track_id) REFERENCES track (track_id)ON UPDATE CASCADE ON DELETE CASCADE);

desc playlist_track;


-- =================================================sql data analysis =======================================================================

-- 1. who is the senior most employee based on job title ?
select * from employee order by levels desc limit 1;


-- 2. which countries have the most invoices ?

select COUNT(*) as c ,billing_country 
 from invoice group by billing_country
 order by c desc;
-- 3. what are top 3 values of total invoices

select total from invoice
order by total desc limit 3;
/*
4 which city has the best customers ? we would like to through a promotional
musci festival in the city we made the most  money.wite ,me a query that returns one city
taht has the highest sum of invoices totals.
Returns both the city name and sum of invoices
*/
select SUM(total)  as invoice_total ,billing_city from invoice
group by billing_city 
order by invoice_total desc ;

select * from invoice;

-- 5. how is the best customer ? who has spent the more money
select c.customer_id,c.first_name,last_name,SUM(i.total )as total 
from customer as c
join invoice as i on c.customer_id=i.customer_id
group by c.customer_id order by total desc limit 1;
 
 /*
 -- 6. write a query to return the email,firstname,lastname and genree of 
 the music listners.Return your list ordred alphabeticaally byemail
 starting wit A'
*/
select * from genre as g where g.name='Rock';
select distinct email,first_name,last_name 
from customer
join invoice on customer.customer_id =invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id IN (
select track_id from track 
join genre ON track.genre_id=genre.genre_id
where genre.name LIKE 'Rock'
)
order by email;
;
/*
-- 6 lets invite the artist whohave written the most rock msic om
our dataset.Write a query that returns the artist name and total
track count of the top 10 rock bands
*/
select artist.artist_id,artist.name,COUNT(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name LIKE 'ROCK'
group by artist.artist_id
order by number_of_songs
limit 10;
/*
-- 7.Return all the track names that have song lehgth longer than
the average song lenght.Return the name and miliseconds for each track.order by 
the song lenght with longest songs  lsit first
*/
select name,milliseconds from track
where milliseconds > (
select AVG(milliseconds) as avg_track_length
from track)
order by milliseconds desc;


/*
--8. find how much amount spent by eacch customer on artists
query to return customer nmae.artist namee andd total spent
*/

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
 SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
/* 9: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* 10: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1