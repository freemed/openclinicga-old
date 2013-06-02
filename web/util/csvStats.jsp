<%@ page import="be.openclinic.statistics.CsvStats,be.mxs.common.util.system.HTMLEntities" %><%@include file="/includes/validateUser.jsp"%><%@ page import="be.mxs.common.util.db.MedwanQuery" %><%@ page import="java.text.SimpleDateFormat" %><%@ page import="java.util.Date" %><%
    String query=null;
	String label="labelfr";
	if(sWebLanguage.equalsIgnoreCase("e")||sWebLanguage.equalsIgnoreCase("en")){
		label="labelen";		
	}
    if("service.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select upper(OC_LABEL_ID) as CODE,OC_LABEL_VALUE as NAME,b.serviceparentid as PARENT" +
                " from OC_LABELS a,ServicesAddressView b " +
                " where " +
                " OC_LABEL_ID=b.serviceid AND " +
                " OC_LABEL_TYPE='service' and " +
                " OC_LABEL_LANGUAGE='"+sWebLanguage+"' " +
                " order by upper(OC_LABEL_ID)";
    }
    else if("labels.list".equalsIgnoreCase(request.getParameter("query"))){
    	if(ScreenHelper.checkString(request.getParameter("tabletype")).equalsIgnoreCase("singlelanguage")){
    		if(request.getParameter("language")!=null){
    			query="select oc_label_type as TYPE,oc_label_id as ID,oc_label_language as LANGUAGE,oc_label_value as LABEL from oc_labels where oc_label_language='"+request.getParameter("language")+"' order by oc_label_type,oc_label_id";
    			System.out.println(query);
    		}
    	}
    	else if(ScreenHelper.checkString(request.getParameter("tabletype")).equalsIgnoreCase("multilanguage")){
    		if(request.getParameter("language")!=null){
        		String languagecolumns="";
        		String[] languages = request.getParameter("language").split(",");
        		for(int n=0;n<languages.length;n++){
        			languagecolumns+=",(select max(oc_label_value) from oc_labels where oc_label_type=a.oc_label_type and oc_label_id=a.oc_label_id and oc_label_language='"+languages[n]+"') "+languages[n].toUpperCase();
        		}
    			query="select a.oc_label_type TYPE,a.oc_label_id ID"+languagecolumns+" from (select distinct oc_label_type,oc_label_id from oc_labels) a order by oc_label_type,oc_label_id";
    			System.out.println(query);
    		}
    	}
    	else if(ScreenHelper.checkString(request.getParameter("tabletype")).equalsIgnoreCase("missinglabels")){
    		if(request.getParameter("sourcelanguage")!=null && request.getParameter("targetlanguage")!=null){
        		String languagecolumns=",(select max(oc_label_value) from oc_labels where oc_label_type=a.oc_label_type and oc_label_id=a.oc_label_id and oc_label_language='"+request.getParameter("targetlanguage")+"') "+request.getParameter("targetlanguage").toUpperCase();
        		String[] languages = request.getParameter("sourcelanguage").split(",");
        		for(int n=0;n<languages.length;n++){
        			languagecolumns+=",(select max(oc_label_value) from oc_labels where oc_label_type=a.oc_label_type and oc_label_id=a.oc_label_id and oc_label_language='"+languages[n]+"') "+languages[n].toUpperCase();
        		}
    			query="select a.oc_label_type TYPE,a.oc_label_id ID"+languagecolumns+" from (select distinct oc_label_type,oc_label_id from oc_labels) a where not exists (select * from oc_labels where oc_label_type=a.oc_label_type and oc_label_id=a.oc_label_id and oc_label_value<>'' and oc_label_language='"+request.getParameter("targetlanguage")+"') order by oc_label_type,oc_label_id";
    			System.out.println(query);
    		}
    	}
    }
    else if("user.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select userid as CODE,firstname as FIRSTNAME,lastname as LASTNAME" +
                " from Users a,Admin b " +
                " where " +
                " a.personid=b.personid " +
                " order by userid";
    }
    else if("prestation.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select OC_PRESTATION_CODE CODE, OC_PRESTATION_DESCRIPTION DESCRIPTION, OC_PRESTATION_PRICE DEFAULTPRICE, OC_PRESTATION_CATEGORIES TARIFFS,OC_PRESTATION_REFTYPE FAMILY,OC_PRESTATION_TYPE TYPE,OC_PRESTATION_INVOICEGROUP INVOICEGROUP,OC_PRESTATION_CLASS CLASS from oc_prestations where (OC_PRESTATION_INACTIVE is NULL OR OC_PRESTATION_INACTIVE<>1) ORDER BY OC_PRESTATION_CODE;";
    }
    else if("debet.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select oc_debet_date as DATE, lastname as NOM,firstname as PRENOM,oc_prestation_description as PRESTATION,oc_debet_quantity as QUANTITE,"+MedwanQuery.getInstance().convert("int","oc_debet_amount")+" as PATIENT,"+MedwanQuery.getInstance().convert("int","oc_debet_insuraramount")+" as ASSUREUR,oc_label_value as SERVICE,oc_debet_credited as ANNULE,replace(oc_debet_patientinvoiceuid,'1.','') as FACT_PATIENT"+
        		" from oc_debets,oc_encounters,adminview,oc_prestations,servicesview,oc_labels"+
        		" where"+
        		" oc_encounter_objectid=replace(oc_debet_encounteruid,'1.','') and"+
        		" oc_prestation_objectid=replace(oc_debet_prestationuid,'1.','') and"+
        		" serviceid=oc_debet_serviceuid and"+
        		" oc_label_type='service' and"+
        		" oc_label_id=serviceid and"+
        		" oc_label_language='fr' and"+
        		" oc_encounter_patientuid=personid and"+
        		" oc_debet_date>="+ MedwanQuery.getInstance().convertStringToDate("'<beginfin>'")+" and"+
        		" oc_debet_date<="+ MedwanQuery.getInstance().convertStringToDate("'<endfin>'")+" ORDER BY oc_debet_date,lastname,firstname";
    }
    else if("global.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,district as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,OC_DIAGNOSIS_AUTHORUID as CODE_USER, OC_DIAGNOSIS_CODETYPE as TYPE, OC_DIAGNOSIS_CODE as DIAGCODE,"
        +"(CASE OC_DIAGNOSIS_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_DIAGNOSIS_CODE) ELSE (select "+label+" from icd10 where code=OC_DIAGNOSIS_CODE) END) as LABEL,OC_DIAGNOSIS_CERTAINTY as CERTAINTY, OC_DIAGNOSIS_GRAVITY as GRAVITY, OC_ENCOUNTER_UPDATEUID as ENCODER"+
        " from OC_ENCOUNTERS_VIEW,AdminView a,PrivateView b,OC_DIAGNOSES c " +
        " where " +
        " OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
        " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
        " b.personid=a.personid AND" +
        " b.stop is null AND" +
        " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
        " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " union "+
        " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,null as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,OC_DIAGNOSIS_AUTHORUID as CODE_USER, OC_DIAGNOSIS_CODETYPE as TYPE, OC_DIAGNOSIS_CODE as DIAGCODE,"
        +"(CASE OC_DIAGNOSIS_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_DIAGNOSIS_CODE) ELSE (select "+label+" from icd10 where code=OC_DIAGNOSIS_CODE) END) as LABEL,OC_DIAGNOSIS_CERTAINTY as CERTAINTY, OC_DIAGNOSIS_GRAVITY as GRAVITY, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                " from OC_ENCOUNTERS_VIEW,AdminView a,OC_DIAGNOSES c " +
                " where " +
                " OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
                " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                " not exists (select * from PrivateView where personid=a.personid) AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
          " union "+
          " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,district as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,null as CODE_USER, null as TYPE, null as DIAGCODE,"
         +"null as LABEL,null as CERTAINTY, null as GRAVITY, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                 " from OC_ENCOUNTERS_VIEW,AdminView a,PrivateView b " +
                 " where " +
                 " not exists (select * from OC_DIAGNOSES where OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+") AND" +
                 " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                 " b.personid=a.personid AND" +
                 " b.stop is null AND" +
                 " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                 " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " union "+
        " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,null as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,null as CODE_USER, null as TYPE, null as DIAGCODE,"
        +"null as LABEL,null as CERTAINTY, null as GRAVITY, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                " from OC_ENCOUNTERS_VIEW,AdminView a " +
                " where " +
                " not exists (select * from OC_DIAGNOSES where OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+") AND" +
                " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                " not exists (select * from PrivateView where personid=a.personid) AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " order by CODE";
    }
    else if("globalrfe.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,district as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,OC_RFE_UPDATEUID as CODE_USER, OC_RFE_CODETYPE as TYPE, OC_RFE_CODE as DIAGCODE,"
        +"(CASE OC_RFE_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_RFE_CODE) ELSE (select "+label+" from icd10 where code=OC_RFE_CODE) END) as LABEL, OC_ENCOUNTER_UPDATEUID as ENCODER"+
        " from OC_ENCOUNTERS_VIEW,AdminView a,PrivateView b,OC_RFE c " +
        " where " +
        " OC_RFE_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
        " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
        " b.personid=a.personid AND" +
        " b.stop is null AND" +
        " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
        " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " union "+
        " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,null as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,OC_RFE_UPDATEUID as CODE_USER, OC_RFE_CODETYPE as TYPE, OC_RFE_CODE as DIAGCODE,"
        +"(CASE OC_RFE_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_RFE_CODE) ELSE (select "+label+" from icd10 where code=OC_RFE_CODE) END) as LABEL, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                " from OC_ENCOUNTERS_VIEW,AdminView a,OC_RFE c " +
                " where " +
                " OC_RFE_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
                " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                " not exists (select * from PrivateView where personid=a.personid) AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
          " union "+
          " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,district as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,null as CODE_USER, null as TYPE, null as DIAGCODE,"
         +"null as LABEL, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                 " from OC_ENCOUNTERS_VIEW,AdminView a,PrivateView b " +
                 " where " +
                 " not exists (select * from OC_RFE where OC_RFE_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+") AND" +
                 " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                 " b.personid=a.personid AND" +
                 " b.stop is null AND" +
                 " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                 " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " union "+
        " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) AS MONTH_OF_BIRTH,gender AS GENDER,"+MedwanQuery.getInstance().datediff("yy","dateofbirth","OC_ENCOUNTER_BEGINDATE")+" as AGE,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,null as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD,null as CODE_USER, null as TYPE, null as DIAGCODE,"
        +"null as LABEL, OC_ENCOUNTER_UPDATEUID as ENCODER"+
                " from OC_ENCOUNTERS_VIEW,AdminView a " +
                " where " +
                " not exists (select * from OC_RFE where OC_RFE_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+") AND" +
                " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
                " not exists (select * from PrivateView where personid=a.personid) AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " order by CODE";
    }
    else if("encounter.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) MONTH_OF_BIRTH,gender GENDER,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,district as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD, OC_ENCOUNTER_UPDATEUID as ENCODER" +
        " from OC_ENCOUNTERS_VIEW,AdminView a,PrivateView b " +
        " where " +
        " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
        " b.personid=a.personid AND" +
        " b.stop is null AND" +
        " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
        " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
        " union "+
        " select "+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'_'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" as CODE,OC_ENCOUNTER_TYPE as TYPE, OC_ENCOUNTER_BEGINDATE as BEGINDATE, OC_ENCOUNTER_ENDDATE as ENDDATE,OC_ENCOUNTER_PATIENTUID as CODE_PATIENT,substring("+ MedwanQuery.getInstance().convertDateToString("dateofbirth")+",4,10) MONTH_OF_BIRTH,gender GENDER,OC_ENCOUNTER_OUTCOME as OUTCOME, OC_ENCOUNTER_DESTINATIONUID as DESTINATION, OC_ENCOUNTER_ORIGIN as ORIGIN,null as DISTRICT,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD, OC_ENCOUNTER_UPDATEUID as ENCODER" +
        " from OC_ENCOUNTERS_VIEW,AdminView a " +
        " where " +
        " OC_ENCOUNTER_PATIENTUID=a.personid AND" +
        " not exists (select * from PrivateView where personid=a.personid) AND" +
        " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
        " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
                " order by CODE";
    }
    else if("wicketcredits.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select oc_wicket_credit_operationdate as DATE,a.oc_label_value as CAISSE,b.oc_label_value as TYPE,"+MedwanQuery.getInstance().convert("int","oc_wicket_credit_amount")+" as MONTANT,oc_wicket_credit_comment as COMMENTAIRE,"+
        		" oc_wicket_credit_invoiceuid as REF_FACTURE,lastname as NOM_UTILISATEUR,firstname as PRENOM_UTILISATEUR"+
        		" from oc_wicket_credits,oc_wickets,oc_labels a,oc_labels b,usersview c,adminview d"+
        		" where"+
        		" oc_wicket_credit_updateuid=userid and"+
        		" c.personid=d.personid and"+
        		" oc_wicket_credit_operationdate >="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" and"+
        		" oc_wicket_credit_operationdate<"+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" and"+
        		" oc_wicket_objectid=replace(oc_wicket_credit_wicketuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
        		" a.oc_label_type='service' and"+
        		" a.oc_label_id=oc_wicket_serviceuid and"+
        		" a.oc_label_language='fr' and"+
        		" b.oc_label_type='credit.type' and"+
        		" b.oc_label_id=oc_wicket_credit_type and"+
        		" b.oc_label_language='fr'"+
        		" order by DATE";
    }
    else if("diagnosis.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select replace(OC_DIAGNOSIS_ENCOUNTERUID,'.','_') as CODE_CONTACT, OC_DIAGNOSIS_AUTHORUID as CODE_USER, OC_DIAGNOSIS_CODETYPE as TYPE, OC_DIAGNOSIS_CODE as CODE,"+
        "(CASE OC_DIAGNOSIS_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_DIAGNOSIS_CODE) ELSE (select "+label+" from icd10 where code=OC_DIAGNOSIS_CODE) END) as LABEL,OC_DIAGNOSIS_CERTAINTY as CERTAINTY, OC_DIAGNOSIS_GRAVITY as GRAVITY,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD" +
                " from OC_DIAGNOSES a,OC_ENCOUNTERS_VIEW " +
                " where " +
                " OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
                " order by OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID";
    }
    else if("rfe.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select replace(OC_RFE_ENCOUNTERUID,'.','_') as CODE_CONTACT, OC_RFE_UPDATEUID as CODE_USER, OC_RFE_CODETYPE as TYPE, OC_RFE_CODE as CODE,"+
        "(CASE OC_RFE_CODETYPE WHEN 'icpc' THEN (select "+label+" from icpc2 where code=OC_RFE_CODE) ELSE (select "+label+" from icd10 where code=OC_RFE_CODE) END) as LABEL,replace(OC_ENCOUNTER_SERVICEUID,'.','_') as CODE_SERVICE,replace(OC_ENCOUNTER_BEDUID,'.','_') as CODE_LIT,replace(OC_ENCOUNTER_MANAGERUID,'.','_') as CODE_WARD" +
                " from OC_RFE a,OC_ENCOUNTERS_VIEW " +
                " where " +
                " OC_RFE_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","OC_ENCOUNTER_OBJECTID")+" AND" +
                " OC_ENCOUNTER_BEGINDATE<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" AND" +
                " OC_ENCOUNTER_ENDDATE>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" " +
                " order by OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID";
    }
    else if("document.list".equalsIgnoreCase(request.getParameter("query"))){
        query="select c.personid as CODE_PATIENT, a.userId as CODE_USER,a.updatetime as REGISTRATIONDATE,b.oc_label_value as TYPE" +
                " from " +
                " Transactions a,oc_labels b,Healthrecord c" +
                " where" +
                " a.healthrecordid=c.healthrecordid and" +
                " b.oc_label_type='web.occup' and" +
                " b.oc_label_id=a.transactionType AND" +
                " b.OC_LABEL_LANGUAGE='"+sWebLanguage+"' AND" +
                " a.updatetime>="+ MedwanQuery.getInstance().convertStringToDate("'<begin>'")+" AND" +
                " a.updatetime<="+ MedwanQuery.getInstance().convertStringToDate("'<end>'")+" " +
                " order by a.updatetime";
    }
    Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
	Connection lad_conn = MedwanQuery.getInstance().getLongAdminConnection();
    CsvStats csvStats = new CsvStats(request.getParameter("begin"), request.getParameter("end"), "admin".equalsIgnoreCase(request.getParameter("db"))?lad_conn:loc_conn, query);
    response.setContentType("application/octet-stream; charset=windows-1252");
    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".csv\"");
    ServletOutputStream os = response.getOutputStream();
    byte[] b = csvStats.execute().toString().getBytes();
    for (int n=0;n<b.length;n++) {
        os.write(b[n]);
    }
    os.flush();
    os.close();
    loc_conn.close();
    lad_conn.close();
%>