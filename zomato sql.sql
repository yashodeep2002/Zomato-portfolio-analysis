
select*from sales;
select*from users;
select*from goldusers_signup;
select*from product;

--1. what is the total amount each user spent on zomato?
select a.userid,sum(b.price) total_amt_spent from sales a inner join product b on a.product_id=b.product_id
group by a.userid;

--2. How many days has each customer visited zomato?
 select userid,count(distinct created_date) from sales group by userid;
 
--3. What is the most purchased item on the menu and how many times was it purchased by all the customers?
 select userid,count(product_id)cnt from sales where product_id=
(select product_id from sales group by product_id order by count(product_id) desc limit 1)
 group by userid;
 
--4. Which product is most popular for each customer?
select * from
(select*,rank()over(partition by userid order by cnt desc)rnk from
(select userid,product_id,count(product_id) cnt from sales group by userid, product_id)a) b
where rnk=1

--5. What is the first product purchased by each customer?
select*from
(select*,rank() over(partition by userid order by created_date)rnk from sales) a where rnk=1

--6. Which item was first purchased by the user after they became a gold member?
 select* from
(select c.*,rank() over(partition by userid order by created_date)rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid 
 and created_date>=gold_signup_date)c)d where rnk=1
 
--7. Which was the first item purchased just before the user became a member?
 select* from
(select c.*,rank() over(partition by userid order by created_date desc)rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid 
 and created_date<gold_signup_date)c)d where rnk=1
 
--8. What is the total orders and amount spent for each member before the become a member?
 select userid,count(created_date)total_orders,sum(price)total_amount_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join goldusers_signup b on a.userid=b.userid 
 and created_date<gold_signup_date)c inner join product d on c.product_id=d.product_id)e 
 group by userid;

--9.If buying each product generates points for eg 5rs=2 zomato pts and each product has different purchasing points
 --for p1 5rs=1 pt, p2 10rs= 5pt, p3 5rs= 1pt . Calculate points collected by each customer and which product has been given most points?
 --Part A
 select userid,sum(total_points) total_points_collected_by_user from
 (select e.*,amount_spent/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.userid,c.product_id,sum(price)amount_spent from
 (select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by userid,product_id)d)e)f
 group by userid;
 
 --Part B
 select product_id,sum(total_points) total_points_for_product, from
 (select e.*,amount_spent/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.userid,c.product_id,sum(price)amount_spent from
 (select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by userid,product_id)d)e)f
 group by product_id order by total_points_for_product desc ;
 
 --10.rank all the transactions of the customers
 select *,rank() over (partition by userid order by created_date)rnk from sales;
  








