use openclinic_dbo;
update oc_encounters set oc_encounter_enddate = oc_encounter_begindate where oc_encounter_type='visit' and oc_encounter_enddate is null;
update oc_encounter_services a, oc_encounters b set 
oc_encounter_serviceenddate=oc_encounter_enddate
where
a.oc_encounter_objectid=b.oc_encounter_objectid and
b.oc_encounter_enddate is not null and
a.oc_encounter_serviceenddate is null;

