// Number of employes and cars in stock for each dealership
MATCH (d:Dealership)
RETURN d.name AS dealership,
       COUNT { (:Employee)-[:WORKS_FOR]->(d) } AS employees,
       COUNT { (:Car)-[:IN_STOCK_AT]->(d) } AS carsInStock
ORDER BY carsInStock DESC;
