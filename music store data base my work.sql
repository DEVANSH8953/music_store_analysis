--------All 11 data sets have been extracted to the MySql workbench-------------
SELECT * FROM music_database.invoice;

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


--------------------------------- TASK 1 the country with maximum invoice-----------------------------------------------------
-------Approach 1
select count(*) as c, billing_country from music_database.invoice
group by billing_country order by c desc; 

-------Approach 2
select count(*) as total_invoices,billing_country  as invoice_count, row_number()
over (order by  billing_country desc ) as rnk from music_database.invoice group by billing_country ;

------Approach 3
with a as (select count(*), billing_country as invoice_count, row_number()
over (order by  billing_country desc ) as rnk from music_database.invoice group by billing_country)
select invoice_count from a where rnk=1; 

------Approach 4
select count(*),billing_country  as invoice_count, row_number()
over (order by  billing_country desc ) as rnk from music_database.invoice group by billing_country  limit 1;

------------------------------------ TASK 2 select top 3 total invoice----------------------------

select total from music_database.invoice order by total desc limit 3;

---------------------------- which city has the best customers----------------------------------------------------

select sum(total) as total_invoice, billing_city from music_database.invoice group by billing_city order by total_invoice desc ;

-------------------- TASK 3 who is the best customer -------------------------------------------

SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) AS total_money_spent FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id 
GROUP BY customer.customer_id, customer.first_name, customer.last_name 
ORDER BY total_money_spent DESC;

----Key Point:-  it is good practice to write the selected column in group by section----------------
 
 ------------------------ Select email, first_name, last_name and genre having rock ----------
 -----------Approach 1
 select distinct email, first_name, last_name 
 from customer 
 join invoice on customer.customer_id = invoice.customer_id
 join invoice_line on invoice_line.invoice_id = invoice.invoice_id
 where track_id in (
 select track_id from track
 join genre on genre.genre_id = track.genre_id 
 where genre.name like 'Rock')
 order by email;

 ----------- Approach 2
 select distinct customer.email,customer.first_name,customer.last_name from customer 
 join invoice on invoice.customer_id = customer.customer_id
 join invoice_line on invoice_line.invoice_id=invoice.invoice_id
 join track on track.track_id = invoice_line.track_id
 join genre on genre.genre_id= track.genre_id
 where genre.name like'ROCK'
 order by customer.email;
 
-------------------------- TASK 4 Artist who have written most of the rock music--------
----------Approach 1
select artist.artist_id,artist.name, count(artist.artist_id) as number_of_songs from track
join album2 ON album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'rock'
group by artist.artist_id,artist.name
order by number_of_songs desc
limit 10;

-----------Approach 2
select artist.name, artist.artist_id, count(artist.artist_id) as number_of_songs
from artist
join album2 on  album2.artist_id = artist.artist_id 
join track on track.album_id=album2.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like'ROCK'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;

-------------------------------- TASK 5 find how much amount is spent by each customer on artists -----------
-------------Approach 1
WITH best_selling_artist AS (
    SELECT
        artist.artist_id,
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sum
    FROM
        invoice_line
        JOIN track ON track.track_id = invoice_line.track_id
        JOIN album2 ON album2.album_id = track.album_id
        JOIN artist ON artist.artist_id = album2.artist_id
    GROUP BY
        artist.artist_id, artist.name
    ORDER BY
        total_sum DESC
)

SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    best_selling_artist.artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_paid
FROM
    invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album2 ON album2.album_id = track.album_id
    JOIN best_selling_artist ON best_selling_artist.artist_id = album2.artist_id
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
ORDER BY
    amount_paid DESC;


-------------------Approach 3

select customer.customer_id,customer.first_name,customer.last_name, artist.name, sum(invoice_line.unit_price* invoice_line.quantity) as total_sales
from invoice
join customer on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
group by customer.customer_id,customer.first_name,customer.last_name, artist.name
order by total_sales desc; 

--------------------------------- TASK 6 most popular music genre for each country-------------------------------
-----------Approach 1
select 
     genre.name,customer.country,
     count(invoice_line.quantity) 
as 
     country_sale
from 
	customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by customer.country,genre.name
order by country_sale desc;

------------Approach 2 (using window function) 
with b as(select genre.name,customer.country
, count(invoice_line.quantity) as quantity_of_sale,
row_number() over(partition by customer.country) as country_wise_sale from customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by customer.country,genre.name
order by quantity_of_sale)
select * from b where country_wise_sale <=1;

------------------------- TAS 7 determine the customer that has spent most on the music for each country ----------------------------
------------Approach 1
with a as (select customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,
sum(total) as amount,
rank() over (partition by invoice.billing_country order by sum(total) desc) as ranking 
from customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
group by invoice.billing_country,customer.first_name,customer.last_name,customer.customer_id
order by invoice.billing_country asc ,amount desc)
select *from a where ranking = 1;


























 
 
 



