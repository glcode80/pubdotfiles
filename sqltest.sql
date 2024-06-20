-- DB: Analyst

show schemas;

show tables from Playground;

CREATE TABLE Playground.testTable (
  id int(10) unsigned NOT NULL primary key AUTO_INCREMENT,
  name1 varchar(20) CHARACTER SET latin1 COLLATE latin1_bin,
  name2 varchar(20) CHARACTER SET latin1 COLLATE latin1_bin,
  counter smallint,
  ratio decimal (10,4),
  lastModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY testTableUIdx1 (name1)
);

insert into Playground.testTable (name1, name2, counter, ratio) values
('peter', 'pan', 5, 2.3),
('kurt', 'cobain', 2, 1.3)
;

select * from Playground.testTable;

drop table Playground.testTable;
