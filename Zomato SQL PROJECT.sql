
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');


CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);



CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


---1 what is the total amount each customer spent on zomato?

select s.userid, sum (p.price) as total_amount from sales as s  
join product p 
on s.product_id = p.product_id
group by s.userid


---2 How many days has each customer visited zomato?

Select distinct userid , count (created_date) as count from sales
group by userid 


---3 What was the first product purchased by each customer?

WITH PRODUCT AS (
SELECT  USERID, created_date, Row_number() OVER (PARTITION BY USERID ORDER BY CREATED_DATE ) AS RNK FROM SALES
)
SELECT  P.USERID, P.CREATED_DATE FROM PRODUCT AS P
WHERE RNK=1
 

---4 What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1
    CAST(p.product_name AS VARCHAR(MAX)) AS product_name,
    COUNT(s.product_id) AS purchase_count
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    CAST(p.product_name AS VARCHAR(MAX))
ORDER BY 
    purchase_count DESC;



----5 Which item was purchased first by customer after they become a member?

with Firstpurchase as (
select s.userid, s.created_date, s.product_id, g.gold_signup_date, row_number() over(partition by s.userid order by created_date) rnk from sales s
join goldusers_signup g on s.userid = g.userid
and s.created_date > g.gold_signup_date)

select f.userid, f.created_date, f.product_id,f.gold_signup_date, f.rnk
from Firstpurchase f 
where f.rnk  =1





--6 Which item was purchased just before the customer become a member?

with purchseditem as (
select s.userid,s.created_date, row_number() over(partition by s.userid order by created_date desc) rnk from sales s 
join goldusers_signup g on s.userid = g.userid and s.created_date <= g.gold_signup_date)

select p.userid, p.created_date,p.rnk from purchseditem p 
where p.rnk = 1



---7  What is the total orders and amount spent for each member before they become a member?

with customersales as(
select s.userid, s.created_date, p.price, row_number() over( partition by s.userid order by created_date desc) rnk from sales s
join goldusers_signup g on s.userid = g.userid 
join product p on s.product_id = p.product_id and s.created_date < g.gold_signup_date) 

select c.userid, count(c.created_date)as T_orders, sum(c.price) as T_amt from customersales c
group by c.userid
 



 --8 Rank all the transactions of the customers

select *, rank() over( partition by userid order by created_date ) as rnk from sales 




 ----9 Which users are the most active (made the most purchases)?

 SELECT TOP 5
    userid,
    COUNT(*) AS purchase_count
FROM 
    sales
GROUP BY 
    userid
ORDER BY 
    purchase_count DESC




----10 Rank transactions directly and mark non-gold member transactions as 'NA'
SELECT 
    s.userid,
    s.created_date,
    p.product_id,
    p.product_name,
    p.price,
    CASE 
        WHEN s.created_date >= g.gold_signup_date THEN 
            CAST(ROW_NUMBER() OVER (PARTITION BY s.userid ORDER BY s.created_date) AS VARCHAR)
        ELSE 'NA'
    END AS transaction_rank
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
LEFT JOIN 
    goldusers_signup g ON s.userid = g.userid
ORDER BY 
    s.userid, s.created_date;
