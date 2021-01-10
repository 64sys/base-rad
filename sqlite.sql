CREATE TABLE IF NOT EXISTS `vendors` (
	`vidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`vname`	TEXT UNIQUE,
	`vaddress`	TEXT,
	`vphone`	TEXT,
	`vemail`	TEXT,
	`vurl`	TEXT
);
CREATE TABLE IF NOT EXISTS `status` (
	`aidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`astatus`	TEXT UNIQUE
);
CREATE TABLE IF NOT EXISTS `uoms` (
	`uidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`uname`	TEXT UNIQUE
);
CREATE TABLE IF NOT EXISTS `divisions` (
	`didx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`dname`	TEXT UNIQUE,
	`ddesc`	TEXT
);
CREATE TABLE IF NOT EXISTS `groups` (
	`gidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`gname`	TEXT UNIQUE,
	`gdesc`	TEXT
);
CREATE TABLE IF NOT EXISTS `comps` (
	`pidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`pname`	TEXT UNIQUE,
	`pdesc`	TEXT
);
CREATE TABLE IF NOT EXISTS `specs` (
	`eidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`ename`	TEXT UNIQUE,
	`edesc`	TEXT
);
CREATE TABLE IF NOT EXISTS `suppcls` (
	`tidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`tname`	TEXT UNIQUE
);
CREATE TABLE IF NOT EXISTS `supplies` (
	`sidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`sname`	TEXT UNIQUE,
	`scode`	TEXT UNIQUE,	
	`sclass`	INTEGER,
	`sdivis`	INTEGER,
	`sgroup`	INTEGER,
	`scomp`	INTEGER,
	`stype`	TEXT,
	`smod`	TEXT,
	`ssize`	TEXT,
	`soper`	TEXT,
	`sspec`	INTEGER,
	`sunit`	INTEGER,
	`samount`	REAL,
	`spict`	TEXT,
	FOREIGN KEY(`sclass`) REFERENCES `suppcls`(`tidx`),
	FOREIGN KEY(`sdivis`) REFERENCES `divisions`(`didx`),
	FOREIGN KEY(`sgroup`) REFERENCES `groups`(`gidx`),
	FOREIGN KEY(`scomp`) REFERENCES `comps`(`pidx`),
	FOREIGN KEY(`sspec`) REFERENCES `specs`(`eidx`),
	FOREIGN KEY(`sunit`) REFERENCES `uoms`(`uidx`)
);
CREATE TABLE IF NOT EXISTS `clients` (
	`cidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`cname`	TEXT UNIQUE,
	`cphone`	TEXT
);
CREATE TABLE IF NOT EXISTS `contractors` (
	`ridx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`rname`	TEXT UNIQUE,
	`rmovile`	TEXT,
	`rphone`	TEXT,
	`rweb`	TEXT,
	`rfax`	TEXT
);
CREATE TABLE IF NOT EXISTS `budgets` (
	`bidx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`bname`	TEXT UNIQUE,
	`bclient`	INTEGER,
	`baddress`	TEXT,
	`bdate`	TEXT,
	`bstatus`	INTEGER,
	`bcontra`	INTEGER,
	`bvat`	REAL,
	`bremark`	TEXT,
	FOREIGN KEY(`bclient`) REFERENCES `clients`(`cidx`),
	FOREIGN KEY(`bstatus`) REFERENCES `status`(`aidx`),
	FOREIGN KEY(`bcontra`) REFERENCES `contractors`(`ridx`)
);
CREATE TABLE IF NOT EXISTS `boms` (
	`midx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`mname`	TEXT UNIQUE,
	`mbud`	INTEGER,
	`msupp`	INTEGER,
	`mqty`	REAL,
	FOREIGN KEY(`mbud`) REFERENCES `budgets`(`bidx`),
	FOREIGN KEY(`msupp`) REFERENCES `supplies`(`sidx`)
);
CREATE VIEW `qty_boms` AS SELECT
	bname AS mbud,
	tname AS mcls,
	total(samount * mqty) As mqty
	FROM boms
LEFT JOIN supplies ON msupp=sidx
LEFT JOIN suppcls ON sclass=tidx
LEFT JOIN budgets ON mbud=bidx
GROUP BY mbud,mcls
;
CREATE VIEW `tot_budgets` AS SELECT
	bidx AS idx,
	bname AS name,
	total(samount * mqty) As amount,
	(total(samount * mqty) * (bvat/100)) As vatamount,
	total(samount * mqty) + (total(samount * mqty) * bvat) As tamount,
        total(samount * mqty) + (total(samount * mqty) * bvat) As camount
	FROM boms
LEFT JOIN supplies ON msupp=sidx
LEFT JOIN budgets ON mbud=bidx
GROUP BY mbud
;
CREATE VIEW `view_budgets` AS SELECT
	bidx,
	bname,
	cname AS bclient,
	cphone AS clientscphone,
	baddress,
	bdate,
	astatus as bstatus,
	rname AS bcontra,
	rmovile AS contractorsrmovile,
	rphone AS contractorsrphone,
	rweb AS contractorsrurl,
	rfax AS contractorsrfax,
	bvat,
	bremark,
	amount AS bamount,
	vatamount AS bvatamount,
	tamount AS btamount,
	camount AS bcamount
	FROM budgets
LEFT JOIN clients ON bclient=cidx
LEFT JOIN contractors ON bcontra=ridx
LEFT JOIN status ON bstatus=aidx
LEFT JOIN tot_budgets ON bidx=idx
;
