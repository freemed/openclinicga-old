<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='2' bgcolor='peachpuff'><b><%=getTran("mobile","biometrics",activeUser) %></b></td></tr>
<%
	String bloodpressure = 	"L: "+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")+
							"/"+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")+
							" mmHg<br/>R: "+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")+
							"/"+MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")+" mmHg";
							
%>
	<tr><td nowrap><%=getTran("openclinic.chuk","bloodpressure",activeUser) %></td><td><%=bloodpressure%></td></tr>
<%
	String pulse = 	MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")+
							" "+getTran("web","bpm",activeUser)+" - "+getTran("web.occup",MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH"),activeUser);
							
	String height=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
	String weight=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
	String BMI="?";
	if(height.length()>0 && weight.length()>0){
		BMI = new DecimalFormat("#.0").format(10000*Double.parseDouble(weight)/(Double.parseDouble(height)*Double.parseDouble(height)));
	}
	String temp=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
%>
	<tr><td nowrap><%=getTran("openclinic.chuk","tracnet.admission.form.hr",activeUser) %></td><td><%=pulse%></td></tr>
	<tr><td nowrap><%=getTran("web","heightincentimeter",activeUser) %></td><td><%=height%></td></tr>
	<tr><td nowrap><%=getTran("web","weightinkilo",activeUser) %></td><td><%=weight%></td></tr>
	<tr><td nowrap><%=getTran("web.occup","medwan.healthrecord.biometry.bmi",activeUser) %></td><td><%=BMI%></td></tr>
	<tr><td nowrap><%=getTran("openclinic.chuk","temperature",activeUser) %></td><td><%=temp%>°C</td></tr>
</table>
