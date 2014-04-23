<%@include file="/mobile/_common/head.jsp"%>

<%
	String bloodpressure = "L: "+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")+
						   "/"+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")+
						   " mmHg<br>R: "+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")+
						   "/"+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")+" mmHg";

	// freq + rythm
	String sFreq = MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
	if(sFreq.length() > 0){
		sFreq+= " "+getTran("web","bpm",activeUser);
	}
	
	String sRythm = getTran("web.occup",MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH"),activeUser);
	
	String pulse = "";
	if(sFreq.length() > 0 && sRythm.length() > 0){
	    pulse = sFreq+" - "+sRythm;
	}
	else if(sFreq.length() > 0){
		pulse = sFreq;
	}
	else{
		pulse = sRythm;
	}
				
	// BMI
	String height = MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT"),
	       weight = MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
	String BMI = "?";
	if(height.length()>0 && weight.length()>0){
		BMI = new DecimalFormat("#.0").format(10000*Double.parseDouble(weight)/(Double.parseDouble(height)*Double.parseDouble(height)));
	}
	
	String temp = MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),ITEM_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
	if(temp.length() > 0){
		temp+= "°C";
	}
%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="2"><%=getTran("mobile","biometrics",activeUser)%></td></tr>
	
	<tr><td class="admin" width="100" nowrap><%=getTran("openclinic.chuk","bloodpressure",activeUser)%></td><td><%=bloodpressure%></td></tr>
	<tr><td class="admin" nowrap><%=getTran("openclinic.chuk","tracnet.admission.form.hr",activeUser)%></td><td><%=pulse%></td></tr>
	<tr><td class="admin" nowrap><%=getTran("web","heightincentimeter",activeUser)%></td><td><%=height%></td></tr>
	<tr><td class="admin" nowrap><%=getTran("web","weightinkilo",activeUser)%></td><td><%=weight%></td></tr>
	<tr><td class="admin" nowrap><%=getTran("web.occup","medwan.healthrecord.biometry.bmi",activeUser)%></td><td><%=BMI%></td></tr>
	<tr><td class="admin" nowrap><%=getTran("openclinic.chuk","temperature",activeUser)%></td><td><%=temp%></td></tr>
</table>
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
    <input type="button" class="button" name="backButton" onclick="showPatientMenu();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
			
<%@include file="/mobile/_common/footer.jsp"%>
