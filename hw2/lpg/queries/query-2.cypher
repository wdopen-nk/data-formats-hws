// Total amount of money spent by each customer
MATCH (c:Car)-[b:BOUGHT_BY]->(p:Customer)
RETURN p.firstName + ' ' + p.lastName AS customer, count(c) AS cars, sum(b.price) AS totalSpentCZK
ORDER BY totalSpentCZK DESC;
