use exam3_87;

select count(*) from products;


select * from customers;
select * from orders;


with cte as(
select customers.*, orderNumber from customers
join orders on customers.customerNumber = orders.customerNumber)
select count(contactFirstName) as aa, contactFirstName from cte group by contactFirstName order by aa desc;

select distinct(status) from orders;

select count(*) AS OH from orders
where status = 'On Hold';

select 4/count(*)*100 from orders;

with cte as(
select orders.*, c.country from orders
join exam3_87.customers c on orders.customerNumber = c.customerNumber)
select count(*) from cte
where orderDate >= '2003-01-01'
and country = 'USA';


select * from products;

select quantityInStock, productVendor from products
order by quantityInStock desc;


select count(customerNumber) aa, employeeNumber from employees
join exam3_87.customers c on employees.employeeNumber = c.salesRepEmployeeNumber
group by employeeNumber order by aa desc;

select officeCode between 1 and 5 from employees order by officeCode;


select *from customers
where customerNumber between 125 and 141;

