// Cars in the stock at a customer's regular dealership, with model the customer already bought
MATCH (p:Customer)<-[:BOUGHT_BY]-(:Car)-[:OF_MODEL]->(m:CarModel)<-[:OF_MODEL]-(offer:Car)-[:IN_STOCK_AT]->(d:Dealership)<-[:REGULAR_CUSTOMER_OF]-(p)
RETURN p.firstName AS customer, m.modelName AS model, offer.color AS color, d.name AS dealership
ORDER BY dealership;
