// Average number of years employees have worked at each dealership
MATCH (e:Employee)-[w:WORKS_FOR]->(d:Dealership)
RETURN d.name AS dealership, count(e) AS employees, avg(duration.between(w.since, date()).years) AS avgYearsEmployed
ORDER BY avgYearsEmployed DESC;
