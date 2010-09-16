create view AccessView
as
select Users.userid,Users.personid,AccessRights.accessright
from Users,AccessRights
where
Users.start <= getdate() and
(Users.stop = null or Users.stop > getdate()) and
Users.userid = AccessRights.userid;
create view AdminView as select * from Admin;
create view exportlabels as select distinct * from Labels where labeltype not in('TRANSACTION_TYPE_LAB_RESULT','MFS','NFS','NIT','Rank','Service','Function');
create view FunctionsView
as
select workid,functionid,functiontype,labeltype,labelid,labelnl,labelfr,labelen from AdminFunctions,Labels
where
Labels.labeltype='Function' and
Labels.labelid = AdminFunctions.functionid and
AdminFunctions.deletetime is null;
create view LocalUnitsView as
select labelid,labelnl,labelfr from Labels
where
labeltype='Service';
create view PrivateView as
select privateid,personid,start,stop,AdminPrivate.comment privatecomment,address,city,zipcode,country,telephone,fax,email,mobile from AdminPrivate;
create view RanksView
as
select workid,rankid,labeltype,labelid,labelnl,labelfr,labelen from AdminWork,Labels
where
((Labels.labeltype='Rank' and Labels.labelid = AdminWork.rankid)
or
(rankid is null and Labels.labeltype = 'Rank' and Labels.labelid= 'Unknown'));
create view RanksView2
as
select AdminWork.*,Labels.labeltype,Labels.labelid,Labels.labelnl,Labels.labelfr,Labels.labelen from AdminWork,Labels
where
Labels.labeltype='Rank' and
Labels.labelid = AdminWork.rankid;
create view ServicesView
as
select workid,serviceid,servicetype,labeltype,labelid,labelnl,labelfr,labelen from AdminServices,Labels
where
Labels.labeltype='Service' and
Labels.labelid = AdminServices.serviceid;
create view UnitGroupsView as select convert(int,linkId) as intLinkId,* from Groups where active=1;
create view UserParametersView as select userid,parameter,value as myvalue,updatetime,active from UserParameters;
create view UsersView as
select * from Users;
create view WorkView as
select AdminWork.workid,AdminWork.personid,telephone,fax,email,AdminWork.start,AdminWork.stop,AdminWork.comment workcomment
, RanksView.labelid rankid, RanksView.labelnl ranknl, RanksView.labelfr rankfr, RanksView.labelen ranken
from AdminWork, RanksView
where AdminWork.workid = RanksView.workid;

