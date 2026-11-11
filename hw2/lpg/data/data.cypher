// === CLEAN START ===
MATCH (n) DETACH DELETE n;

// === CONSTRAINTS ===
CREATE CONSTRAINT dealership_id IF NOT EXISTS FOR (d:Dealership) REQUIRE d.id IS UNIQUE;
CREATE CONSTRAINT person_id     IF NOT EXISTS FOR (p:Person)     REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT car_model_id  IF NOT EXISTS FOR (m:CarModel)   REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT car_id        IF NOT EXISTS FOR (c:Car)        REQUIRE c.id IS UNIQUE;


// === DATA ARRAYS ===
// DEALERSHIPS 
WITH [
  {id:'praha',   name:'AutoCentrum Praha',   address:'Pod Chodovem 1267/7, 140 00 Praha 4-Chodov',          foundedDate:'2003-05-17'},
  {id:'brno',    name:'AutoCentrum Brno',    address:'Poříčí 805/1c, 603 00 Brno-střed',                    foundedDate:'2009-03-12'},
  {id:'ostrava', name:'AutoCentrum Ostrava', address:'Cihelní 3160/49b, 702 00 Moravská Ostrava a Přívoz', foundedDate:'2016-10-03'}
] AS rows
UNWIND rows AS r
MERGE (d:Dealership {id:r.id})
  SET d.name        = r.name,
      d.address     = r.address,
      d.foundedDate = date(r.foundedDate);

// EMPLOYEES 
WITH [
  {id:'jan-novak',      firstName:'Jan',    lastName:'Novak',    phones:['+420774034587', '+420356756489'], worksFor:'praha', since:'2018-04-17', position:'salesperson'},
  {id:'petra-maximoff', firstName:'Petra',  lastName:'Maximoff', phones:['+420602555666'],                  worksFor:'praha', since:'2021-09-01', position:'mechanic'},
  {id:'thomas-wayne',   firstName:'Thomas', lastName:'Wayne',    phones:[],                                 worksFor:'brno',  since:'2012-02-01', position:'manager'}
] AS rows
UNWIND rows AS r
MERGE (p:Person {id:r.id})
  SET p:Employee,
      p.firstName    = r.firstName,
      p.lastName     = r.lastName,
      p.phoneNumbers = CASE WHEN size(r.phones) = 0 THEN null ELSE r.phones END   // no phone -> no property
WITH p, r
MATCH (d:Dealership {id:r.worksFor})
MERGE (p)-[w:WORKS_FOR]->(d)
  SET w.since    = date(r.since),
      w.position = r.position;

// CUSTOMERS
WITH [
  {id:'bruce-churkobesovich', firstName:'Bruce',  lastName:'Churkobesovich', phones:['+420603777888'],
     regularCustomerOf:[{dealer:'praha', since:'2022-06-15'}, {dealer:'brno', since:'2023-02-20'}]},
  {id:'martin-prochazka',     firstName:'Martin', lastName:'Prochazka',      phones:[],
     regularCustomerOf:[{dealer:'praha', since:'2021-11-03'}]},
  {id:'alice-kucerova',       firstName:'Alice',  lastName:'Kucerova',       phones:['+420604999345'],
     regularCustomerOf:[]}
] AS rows
UNWIND rows AS r
MERGE (p:Person {id:r.id})
  SET p:Customer,
      p.firstName    = r.firstName,
      p.lastName     = r.lastName,
      p.phoneNumbers = CASE WHEN size(r.phones) = 0 THEN null ELSE r.phones END
WITH p, r
UNWIND r.regularCustomerOf AS rc
MATCH (d:Dealership {id:rc.dealer})
MERGE (p)-[x:REGULAR_CUSTOMER_OF]->(d)
  SET x.since = date(rc.since);

// CAR MODELS 
WITH [
  {id:'octavia-iv', modelName:'Octavia IV', debutDate:'2019-11-11', enginePower:110},
  {id:'911-ii',     modelName:'911 II',     debutDate:'1973-10-04', enginePower:150},
  {id:'matiz-i',    modelName:'Matiz I',    debutDate:'1998-03-05', enginePower:70},
  {id:'kodiaq-ii',  modelName:'Kodiaq II',  debutDate:'2023-10-04', enginePower:180}
] AS rows
UNWIND rows AS r
MERGE (m:CarModel {id:r.id})
  SET m.modelName   = r.modelName,
      m.debutDate   = date(r.debutDate),
      m.enginePower = r.enginePower;

// CARS 
WITH [
  {id:'car-1', vin:'TMBAJ7NXXR0526018', color:'black',  manufacturedDate:'2024-02-12', model:'octavia-iv'},
  {id:'car-2', vin:'TMBAG7NXXP0159083', color:'silver', manufacturedDate:'2023-11-05', model:'octavia-iv'},
  {id:'car-3', vin:'KLAMA48S3NB016613', color:'purple', manufacturedDate:'2022-05-20', model:'matiz-i'},
  {id:'car-4', vin:'WP0ZZZ911ES186091', color:'red',    manufacturedDate:'1984-07-03', model:'911-ii'},
  {id:'car-5', vin:'KLAMA48SXRB390996', color:'white',  manufacturedDate:'2024-08-30', model:'matiz-i'},
  {id:'car-6', vin:'TMBJR7NS4R0030824', color:'green',  manufacturedDate:'2024-05-14', model:'octavia-iv'}
] AS rows
UNWIND rows AS r
MERGE (c:Car {id:r.id})
  SET c.vin              = r.vin,
      c.color            = r.color,
      c.manufacturedDate = date(r.manufacturedDate)
WITH c, r
MATCH (m:CarModel {id:r.model})
MERGE (c)-[:OF_MODEL]->(m);

// CARS IN STOCK  (IN_STOCK_AT with edge property) 
WITH [
  {car:'car-1', dealer:'praha', since:'2024-03-01'},
  {car:'car-2', dealer:'brno',  since:'2023-12-04'},
  {car:'car-5', dealer:'praha', since:'2024-09-16'}
] AS rows
UNWIND rows AS r
MATCH (c:Car        {id:r.car})
MATCH (d:Dealership {id:r.dealer})
MERGE (c)-[s:IN_STOCK_AT]->(d)
  SET s.since = date(r.since);

// SOLD CARS  (BOUGHT_BY with edge properties, price in CZK)
WITH [
  {car:'car-3', customer:'alice-kucerova',       date:'2022-07-15', price:189000},
  {car:'car-4', customer:'bruce-churkobesovich', date:'2019-08-20', price:1450000},
  {car:'car-6', customer:'bruce-churkobesovich', date:'2024-06-08', price:714000}
] AS rows
UNWIND rows AS r
MATCH (c:Car             {id:r.car})
MATCH (p:Person:Customer {id:r.customer})
MERGE (c)-[b:BOUGHT_BY]->(p)
  SET b.date  = date(r.date),
      b.price = r.price;

RETURN 'LPG import finished' AS status;
