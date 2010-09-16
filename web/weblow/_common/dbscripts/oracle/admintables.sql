CREATE TABLE AccessCodes (
	documentid int NULL ,
	accesscode varchar (255) NULL
);
CREATE TABLE AccessLogs (
	userid int NULL ,
	accesstime date NULL
);
CREATE TABLE AccessRights (
	userid int NULL ,
	accessright varchar (255) NULL ,
	updatetime date NULL ,
	active int NULL
);
CREATE TABLE Admin (
	personid int NULL ,
	natreg varchar (11) NULL ,
	immatold varchar (25) NULL ,
	immatnew varchar (25) NULL ,
	candidate varchar (25) NULL ,
	lastname varchar (255) NULL ,
	firstname varchar (255) NULL ,
	gender varchar (1) NULL ,
	dateofbirth date NULL ,
	"comment" varchar (255) NULL ,
	sourceid varchar (1) NULL ,
	language varchar (1) NULL ,
	engagement date NULL ,
	pension date NULL ,
	statute varchar (1) NULL ,
	claimant varchar (1) NULL ,
	searchname varchar (255) NULL ,
	updatetime date NULL ,
	claimant_expiration date NULL ,
	native_country varchar (2) NULL ,
	native_town varchar (255) NULL ,
	motive_end_of_service varchar (3) NULL ,
	startdate_inactivity date NULL ,
	enddate_inactivity date NULL ,
	code_inactivity varchar (3) NULL ,
	update_status varchar (1) NULL ,
	person_type varchar (1) NULL ,
	situation_end_of_service varchar (1) NULL ,
	updateuserid int NULL ,
	comment1 varchar (255) NULL ,
	comment2 varchar (255) NULL ,
	comment3 varchar (255) NULL ,
	comment4 varchar (255) NULL ,
	comment5 varchar (255) NULL ,
	middlename varchar (255) NULL ,
	begindate date NULL ,
	enddate date NULL
);
CREATE TABLE AdminExtends (
	personid int NULL ,
	extendid int NULL ,
	extendtype varchar (255) NULL ,
	labelid varchar (255) NULL ,
	extendvalue varchar (255) NULL ,
	updatetime date NULL ,
	updateuserid int NULL
);
CREATE TABLE AdminFunctions (
	workid int NULL ,
	functionid varchar (255) NULL ,
	functiontype varchar (1) NULL ,
	updatetime date NULL ,
	functioncategory varchar (255) NULL ,
	deletetime date NULL
);
CREATE TABLE AdminHistory (
	personid int NOT NULL ,
	natreg varchar (11) NULL ,
	immatold varchar (25) NULL ,
	immatnew varchar (25) NULL ,
	candidate varchar (25) NULL ,
	lastname varchar (100) NOT NULL ,
	firstname varchar (100) NULL ,
	gender char (1) NULL ,
	dateofbirth date NULL ,
	"comment" varchar (255) NULL ,
	sourceid char (1) NULL ,
	language char (1) NULL ,
	engagement date NULL ,
	pension date NULL ,
	statute char (1) NULL ,
	claimant char (1) NULL ,
	searchname varchar (100) NULL ,
	updatetime date NULL ,
	claimant_expiration date NULL ,
	native_town varchar (100) NULL ,
	motive_end_of_service char (3) NULL ,
	startdate_inactivity date NULL ,
	enddate_inactivity date NULL ,
	code_inactivity char (3) NULL ,
	update_status char (1) NULL ,
	person_type char (1) NULL ,
	situation_end_of_service char (1) NULL ,
	updateuserid int NULL ,
	comment1 varchar (100) NULL ,
	comment2 varchar (100) NULL ,
	comment3 varchar (100) NULL ,
	comment4 varchar (100) NULL ,
	comment5 varchar (100) NULL ,
	native_country varchar (100) NULL ,
	middlename varchar (255) NULL ,
	begindate date NULL ,
	enddate date NULL
);
CREATE TABLE AdminPhysicians (
	personid int NOT NULL ,
	PhysicianLastname varchar (255) NULL ,
	PhysicianFirstname varchar (255) NULL ,
	PhysicianAddress varchar (255) NULL ,
	PhysicianZipcode varchar (255) NULL ,
	PhysicianCity varchar (255) NULL ,
	PhysicianPhone varchar (255) NULL ,
	PhysicianSendReport int NULL ,
	updatetime date NULL ,
	updateuserid int NULL
);
CREATE TABLE AdminPrivate (
	privateid int NULL ,
	personid int NULL ,
	"start" date NULL ,
	"stop" date NULL ,
	address varchar (255) NULL ,
	city varchar (255) NULL ,
	zipcode varchar (10) NULL ,
	country varchar (2) NULL ,
	telephone varchar (255) NULL ,
	fax varchar (255) NULL ,
	mobile varchar (255) NULL ,
	email varchar (255) NULL ,
	"comment" varchar (255) NULL ,
	updatetime date NULL ,
	"type" varchar (255) NULL
);
CREATE TABLE AdminServices (
	workid int NULL ,
	serviceid varchar (255) NULL ,
	servicetype varchar (1) NULL ,
	updatetime date NULL
);

CREATE TABLE AlternateID (
	personid int NULL ,
	alternateid varchar (255) NULL
);
CREATE TABLE ContractLabels (
	labeltype varchar (255) NULL ,
	labelid varchar (255) NULL ,
	labelnl varchar (255) NULL ,
	labelfr varchar (255) NULL ,
	labelen varchar (255) NULL ,
	updatetime date NULL ,
	doNotShowLink int  NULL ,
	updateuserid int NULL
);
CREATE TABLE Contracts (
	serviceid varchar (255) NULL ,
	address varchar (255) NULL ,
	city varchar (255) NULL ,
	zipcode varchar (10) NULL ,
	country varchar (2) NULL ,
	telephone varchar (255) NULL ,
	fax varchar (255) NULL ,
	"comment" varchar (255) NULL ,
	updatetime date NULL ,
	email varchar (255) NULL ,
	parentserviceid varchar (50) NULL ,
	code1 varchar (50) NULL ,
	code2 varchar (50) NULL ,
	code3 varchar (50) NULL ,
	code4 varchar (50) NULL ,
	code5 varchar (50) NULL ,
	parentid varchar (255) NULL ,
	serviceparentid varchar (255) NULL ,
	servicelanguage varchar (2) NULL ,
	serviceorder varchar (2) NULL ,
	inscode varchar (255) NULL ,
	updateuserid int NULL ,
	contract varchar (255) NULL ,
	contracttype varchar (255) NULL ,
	contactperson varchar (255) NULL
);
CREATE TABLE Counters (
	name varchar (255) NULL ,
	counter int NULL
);
CREATE TABLE Documents (
	documentid int NULL ,
	personid int NULL ,
	folderid int NULL ,
	author varchar (255) NULL ,
	"date" date NULL ,
	title varchar (255) NULL ,
	"summary" varchar (255) NULL ,
	uri varchar (255) NULL ,
	mimetype varchar (255) NULL
);
CREATE TABLE EPSServices (
	EPSID int NOT NULL ,
	serviceid varchar (255) NULL ,
	updatetime date NULL ,
	updateuserid int NULL ,
	deletedate date NULL
);
CREATE TABLE ExternalPreventionServices (
	EPSID int NOT NULL ,
	EPSName varchar (255) NULL ,
	EPSAddress varchar (255) NULL ,
	EPSZipcode varchar (255) NULL ,
	EPSCity varchar (255) NULL ,
	EPSPhone varchar (255) NULL ,
	EPSFax varchar (255) NULL ,
	EPSPhysicianLastname varchar (255) NULL ,
	EPSPhysicianFirstname varchar (255) NULL ,
	updatetime date NULL ,
	updateuserid int NULL ,
	deletedate date NULL
);
CREATE TABLE Groups (
	"id" int NULL ,
	groupType varchar (255) NULL ,
	groupName varchar (255) NULL ,
	linkId varchar (50) NULL ,
	active int NULL ,
	updatetime date NULL
);
CREATE TABLE Labels (
	labeltype varchar (255) NULL ,
	labelid varchar (255) NULL ,
	labelnl varchar (255) NULL ,
	labelfr varchar (255) NULL ,
	labelen varchar (255) NULL ,
	updatetime date NULL ,
	doNotShowLink int NULL ,
	updateuserid int NULL
);
CREATE TABLE MedicalCenters (
	code varchar (255) NULL ,
	name varchar (255) NULL
);

CREATE TABLE Personnel (
	code varchar (255) NULL ,
	name varchar (255) NULL
);
CREATE TABLE Providers (
	code varchar (255) NULL ,
	name varchar (255) NULL
);
CREATE TABLE Services (
	serviceid varchar (255) NULL ,
	address varchar (255) NULL ,
	city varchar (255) NULL ,
	zipcode varchar (10) NULL ,
	country varchar (2) NULL ,
	telephone varchar (255) NULL ,
	fax varchar (255) NULL ,
	"comment" varchar (255) NULL ,
	updatetime date NULL ,
	email varchar (255) NULL ,
	parentserviceid varchar (50) NULL ,
	code1 varchar (50) NULL ,
	code2 varchar (50) NULL ,
	code3 varchar (50) NULL ,
	code4 varchar (50) NULL ,
	code5 varchar (50) NULL ,
	parentid varchar (255) NULL ,
	serviceparentid varchar (255) NULL ,
	servicelanguage varchar (2) NULL ,
	serviceorder varchar (2) NULL ,
	inscode varchar (255) NULL ,
	updateuserid int NULL ,
	contract varchar (255) NULL ,
	contracttype varchar (255) NULL ,
	contactperson varchar (255) NULL ,
	contractdate date NULL
);
CREATE TABLE Support (
	supportID int NULL ,
	supportName varchar (255) NULL ,
	supportDate date NULL ,
	supportFrom date NULL ,
	supportUntil date NULL ,
	supportLocationID varchar (255) NULL ,
	supportTask clob NULL ,
	supportDuration date NULL
);
CREATE TABLE UnknownLabels (
	labeltype varchar (255) NULL ,
	labelid varchar (255) NULL ,
	unknowndate date NULL ,
	updatetime date NULL ,
	updateuserid int NULL
);
CREATE TABLE UpdateErrors (
	updatetime date NULL ,
	"comment" varchar (255) NULL ,
	xml clob NULL
);
CREATE TABLE UserParameters (
	userid int NULL ,
	parameter varchar (255) NULL ,
	"value" varchar (255) NULL ,
	updatetime date NULL ,
	active int NULL
);
CREATE TABLE UserProfileMotivations (
	userid int NULL ,
	patientid int NULL ,
	updatetime date NULL ,
	motivation varchar (255) NULL ,
	screenid varchar (255) NULL
);
CREATE TABLE UserProfilePermissions (
	userprofileid int NULL ,
	screenid varchar (255) NULL ,
	permission varchar (255) NULL ,
	active int NULL ,
	updatetime date NULL
);
CREATE TABLE UserProfiles (
	userprofileid int NULL ,
	userprofilename varchar (255) NULL ,
	updatetime date NULL
);
CREATE TABLE Users (
	userid int NULL ,
	personid int NULL ,
	"start" date NULL ,
	"stop" date NULL ,
	updatetime date NULL ,
	project varchar (255) NULL ,
	encryptedpassword blob NULL
);
CREATE TABLE UserServices (
	userid int NULL ,
	serviceid varchar (255) NULL ,
	updatetime date NULL ,
	activeservice int NULL
);
CREATE TABLE Zipcodes (
	zipcode varchar (255) NOT NULL ,
	citynl varchar (255) NULL ,
	cityfr varchar (255) NULL ,
	cityen varchar (255) NULL
);


