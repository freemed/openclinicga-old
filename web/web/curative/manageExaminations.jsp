<%@page import="be.dpms.medwan.common.model.vo.occupationalmedicine.VerifiedExaminationVO,
                java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("curative","select",activeUser)%>
 <%!
    private String writeExamination(User activeUser, int counter, String sTranTitle,String sTranDate,String sTranType, String sTranId, String sTranServerId, String sWebLanguage, String sCONTEXTPATH){
        return "<tr onmouseover=\"this.className='list_select2';\" onmouseout=\"this.className='';\">"
        +"<td>"
            +"<img src='"+sCONTEXTPATH+"/_img/pijl.gif'>"
            +"<button accesskey='"+counter+"' class='buttoninvisible' onclick=\"window.location.href='"+sCONTEXTPATH+"/healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&ts="+getTs()+"'\"></button>"
            +"<u>"+(counter)+"</u> "+sTranTitle
        +"</td>"
        +"<td align='center'>"
            +"<a onmouseover=\"window.status='';return true;\" href=\""+sCONTEXTPATH+"/healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&ts="+getTs()+"\">"
                +getTran("Web.Occup","medwan.common.new",sWebLanguage)
            +"</a>"
        +"</td>"
        +"<td align='center'>"
            +"<a onmouseover=\"window.status='';return true;\" href=\""+sCONTEXTPATH+"/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType="+sTranType+"&be.mxs.healthrecord.createTransaction.context="+activeUser.activeService.defaultContext+"&be.mxs.healthrecord.transaction_id="+sTranId+"&be.mxs.healthrecord.server_id="+sTranServerId+"&ts="+getTs()+"\">"
                +sTranDate
            +"</a>"
        +"</td>"
        +"<td/><td/>"
    +"</tr>";
    }
%>
<table width="100%" cellspacing="0" cellpadding="2" class="menu">
    <tr class="admin">
        <td colspan="5">&nbsp;<%=getTran("web","documents",sWebLanguage)%></td>
    </tr>
    <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
        <td colspan="5">
            <img src="<c:url value="/_img/pijl.gif"/>">&nbsp;
            <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_EXTERNAL_DOCUMENT&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&ts=<%=getTs()%>"><%=getTran("Web","add.new.document",sWebLanguage)%></a>
        </td>
    </tr>
    <%-- HEADER --%>
    <%
        int counter = 0;

       SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
       sessionContainerWO.init(activePatient.personid);

       Vector userServiceExams = ScreenHelper.getExaminationsForServiceIncludingParents(activeUser.activeService.code, activeUser.person.language);
       userServiceExams = sessionContainerWO.getHealthRecordVO().getVerifiedExaminations(sessionContainerWO, userServiceExams);

       VerifiedExaminationVO verifiedExaminationVO;

       String examName;
       Hashtable exams = new Hashtable();

       if(activeUser.getAccessRight("examinations.global.select")){
    %>
    <tr class="admin">
        <td width="400">&nbsp;<%=getTran("web","globalexaminations",sWebLanguage)%></td>
        <td width="100"/>
        <td align="center" width="100"><%=getTran("web","lastexamination",sWebLanguage)%></td>
        <td align="center" width="100"><%=getTran("web","planned",sWebLanguage)%></td>
        <td/>
    </tr>
 <%

    for (int n=0; n<userServiceExams.size(); n++) {
        verifiedExaminationVO = (VerifiedExaminationVO) userServiceExams.get(n);
        examName = getTran("examination", verifiedExaminationVO.examinationId + "", sWebLanguage);

        exams.put(examName, verifiedExaminationVO);
    }

    String sTTNursing = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_SURVEILLANCE_PROTOCOL";
    String sTranNursing = getTran("web.occup", sTTNursing, sWebLanguage);
    TransactionVO tranNursing = sessionContainerWO.getLastTransaction(sTTNursing);
    String sNursingTranId = "";
    String sNursingServerId = "";
    String sNursingDate = "";

    if (tranNursing!=null){
        sNursingTranId = tranNursing.getTransactionId().intValue()+"";
        sNursingServerId = tranNursing.getServerId()+"";
        sNursingDate = new SimpleDateFormat("dd/MM/yyyy").format(tranNursing.getUpdateTime());
    }

    String sTTLabo = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST";
    String sTranLabo = getTran("web.occup", sTTLabo, sWebLanguage);
    TransactionVO tranLabo = sessionContainerWO.getLastTransaction(sTTLabo);

    String sLaboTranId = "";
    String sLaboServerId = "";
    String sLaboDate = "";

    if (tranLabo!=null){
        sLaboTranId = tranLabo.getTransactionId().intValue()+"";
        sLaboServerId = tranLabo.getServerId()+"";
        sLaboDate = new SimpleDateFormat("dd/MM/yyyy").format(tranLabo.getUpdateTime());
    }

    String sTTAna = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ANATOMOPATHOLOGY";
    String sTranAna = getTran("web.occup", sTTAna, sWebLanguage);
    TransactionVO tranAna = sessionContainerWO.getLastTransaction(sTTAna);

    String sAnaTranId = "";
    String sAnaServerId = "";
    String sAnaDate = "";

    if (tranAna!=null){
        sAnaTranId = tranAna.getTransactionId().intValue()+"";
        sAnaServerId = tranAna.getServerId()+"";
        sAnaDate = new SimpleDateFormat("dd/MM/yyyy").format(tranAna.getUpdateTime());
    }

    String sTTMir = "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2";
    String sTranMir = getTran("web.occup", sTTMir, sWebLanguage);
    TransactionVO tranMir = sessionContainerWO.getLastTransaction(sTTMir);
    String sMirTranId = "";
    String sMirServerId = "";
    String sMirDate = "";

    if (tranMir!=null){
        sMirTranId = tranMir.getTransactionId().intValue()+"";
        sMirServerId = tranMir.getServerId()+"";
        sMirDate = new SimpleDateFormat("dd/MM/yyyy").format(tranMir.getUpdateTime());
    }

    String sTTReference ="be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_REFERENCE";
    String sTranReference = getTran("web.occup", sTTReference, sWebLanguage);
    TransactionVO tranReference = sessionContainerWO.getLastTransaction(sTTReference);

    String sReferenceTranId = "";
    String sReferenceServerId = "";
    String sReferenceDate = "";

    if (tranReference!=null){
        sReferenceTranId = tranReference.getTransactionId().intValue()+"";
        sReferenceServerId = tranReference.getServerId()+"";
        sReferenceDate = new SimpleDateFormat("dd/MM/yyyy").format(tranReference.getUpdateTime());
    }

     //NURSING

     if(activeUser.getAccessRight("occup.surveillance.select")) out.print(writeExamination(activeUser,counter++,sTranNursing,sNursingDate,sTTNursing,sNursingTranId,sNursingServerId,sWebLanguage, sCONTEXTPATH));
     if(activeUser.getAccessRight("occup.labrequest.select")) out.print(writeExamination(activeUser,counter++,sTranLabo,sLaboDate,sTTLabo,sLaboTranId,sLaboServerId,sWebLanguage, sCONTEXTPATH));
     if(activeUser.getAccessRight("occup.medicalimagingrequest.select")) out.print(writeExamination(activeUser,counter++,sTranMir,sMirDate,sTTMir,sMirTranId,sMirServerId,sWebLanguage, sCONTEXTPATH));
     if(activeUser.getAccessRight("occup.anatomopathology.select")) out.print(writeExamination(activeUser,counter++,sTranAna,sAnaDate,sTTAna,sAnaTranId,sAnaServerId,sWebLanguage, sCONTEXTPATH));
     if(activeUser.getAccessRight("occup.reference.select")) out.print(writeExamination(activeUser,counter++,sTranReference,sReferenceDate,sTTReference,sReferenceTranId,sReferenceServerId,sWebLanguage, sCONTEXTPATH));

     //REFERENCES
 %>
    <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
        <%-- examination name --%>
        <td>
            <img src="<c:url value="/_img/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="window.location.href='<c:url value='/main.do'/>?Page=healthrecord/globalReferenceEdit.jsp&ts=<%=getTs()%>'"></button><u><%=counter++%></u> <%=getTran("web","internal_references",sWebLanguage)%>
        </td>
        <%-- create --%>
        <td align="center">
            <a onmouseover="window.status='';return true;" href="<c:url value='/main.do'/>?Page=healthrecord/globalReferenceEdit.jsp&ts=<%=getTs()%>">
                <%=getTran("Web.Occup","medwan.common.new",sWebLanguage)%>
            </a>
        </td>
        <td/><td/><td/>
    </tr>
    <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
        <%-- examination name --%>
        <td>
            <img src="<c:url value="/_img/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="window.location.href='<c:url value='/main.do'/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>'"></button><u><%=counter++%></u> <a href="<c:url value='/main.do'/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>"><%=getTran("web","internal_references_summary",sWebLanguage)%></a>
        </td>
        <td/><td/><td/><td/>
    </tr>
    <%
        if(activeUser.getAccessRight("prescriptions.care.select")){
    %>
    <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
        <%-- examination name --%>
        <td>
            <img src="<c:url value="/_img/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="window.location.href='<c:url value='/main.do'/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>'"></button><u><%=counter++%></u> <a href="javascript:openPopup('medical/manageCarePrescriptionsPopup.jsp',700,400);"><%=getTran("web","careprescriptions",sWebLanguage)%></a>
        </td>
        <td/><td/><td/><td/>
    </tr>
    <%
        }
        if(activeUser.getAccessRight("prescriptions.drugs.select")){
    %>
    <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
        <%-- examination name --%>
        <td>
            <img src="<c:url value="/_img/pijl.gif"/>"><button accesskey="<%=counter%>" class="buttoninvisible" onclick="window.location.href='<c:url value='/main.do'/>?Page=healthrecord/globalReferenceSummary.jsp&ts=<%=getTs()%>'"></button><u><%=counter++%></u> <a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp',700,400);"><%=getTran("web","medications",sWebLanguage)%></a>
        </td>
        <td/><td/><td/><td/>
    </tr>
    <%
            }
        }
        Vector examNames = new Vector(exams.keySet());
        if(activeUser.getAccessRight("examinations.specific.select")){
    %>
    <%-- PAGE TITLE --%>
    <tr class="admin">
        <td>&nbsp;<%=getTran("web","specificexaminations",sWebLanguage)%> (<%=getTran("Service",activeUser.activeService.code,sWebLanguage)%>)</td>
        <td/>
        <td align="center"><%=getTran("web","lastexamination",sWebLanguage)%></td>
        <td align="center"><%=getTran("web","planned",sWebLanguage)%></td>
        <td/>
    </tr>
    <%-- DYNAMIC LINKS --------------------------------------------------------------------------%>
    <%

        Collections.sort(examNames);
        for (int n=0; n<examNames.size(); n++) {
            examName = (String) examNames.get(n);
            verifiedExaminationVO = (VerifiedExaminationVO) exams.get(examName);
            if(MedwanQuery.getInstance().getConfigString("noShowExaminationsGender"+activePatient.gender,"").indexOf(verifiedExaminationVO.getTransactionType())<0){
            %>
            <tr class="<%=(verifiedExaminationVO.getPlannedExaminationDue().equalsIgnoreCase("medwan.common.true")?"menuItemRed":"")%>" onmouseover="this.className='list_select2';" onmouseout="this.className='<%=(verifiedExaminationVO.getPlannedExaminationDue().equalsIgnoreCase("medwan.common.true")?"menuItemRed":"")%>';">
                <%-- examination name --%>
                <td><img src="<c:url value="/_img/pijl.gif"/>"><button class='buttoninvisible'></button>  <%=examName%></td>
                <%-- create --%>
                <td align="center">
                    <%
                        if (((verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY"))
                        &&(checkString(verifiedExaminationVO.getLastExamination()).length()==0))
                        ||(!verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY"))
                        &&(!verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_PEDIATRY_DELIVERY"))){
                    %>
                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&ts=<%=getTs()%>">
                        <%=getTran("Web.Occup","medwan.common.new",sWebLanguage)%>
                    </a>
                    <%
                        }
                    %>
                </td>
                <%-- edit (last examination date) --%>
                <td align="center">
                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
                        <%=checkString(verifiedExaminationVO.getLastExamination())%>
                    </a>
                </td>
                <%-- edit (planned examination date) --%>
                <td align="center">
                    <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>">
                        <%=checkString(verifiedExaminationVO.getPlannedExaminationDueDateString())%>
                    </a>
                </td>
                <td/>
            </tr>
            <%
            }
        }
    %>
    <%-- OTHER SERVICES AND THEIR EXAMINATIONS --------------------------------------------------%>
    <tr id="otherServicesHeader" onClick="toggleOtherServices();" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" height="15">
        <td colspan="5">
            <img src="<c:url value="/_img/pijl.gif"/>"><a href="#"><b>&nbsp;<%=getTran("Web.manage","examinationsofotherservices",sWebLanguage)%></b></a>
        </td>
    </tr>
<%
    }
%>
</table>

<table width="100%" cellspacing="1" cellpadding="1" class="menu" id="otherServicesTable" style="display:none;">
    <%
        try{
        Hashtable otherServices = ScreenHelper.getServiceContexts();
        otherServices.remove(activeUser.activeService.code);

        // run thru other services, displaying their linked examinations
        String serviceId, defaultContext, sClass = "1";
        String showExamsTran = getTran("web.manage", "showExaminations", sWebLanguage);
        Vector otherServiceExams;

        Enumeration servicesEnum = otherServices.keys();
        while (servicesEnum.hasMoreElements()) {
            serviceId = (String) servicesEnum.nextElement();
            defaultContext = (String) otherServices.get(serviceId);

            // get examinations linked to current service
            otherServiceExams = ScreenHelper.getExaminationsForService(serviceId, activeUser.person.language);

            if (otherServiceExams.size() > 0) {
                sessionContainerWO.getHealthRecordVO().setUpdated(true);
                otherServiceExams = sessionContainerWO.getHealthRecordVO().getVerifiedExaminations(sessionContainerWO, otherServiceExams);

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                Hashtable otherExams = new Hashtable();
                for(int n=0; n<otherServiceExams.size(); n++){
                    verifiedExaminationVO = (VerifiedExaminationVO)otherServiceExams.get(n);
                    if(MedwanQuery.getInstance().getConfigString("noShowExaminationsGender"+activePatient.gender,"").indexOf(verifiedExaminationVO.getTransactionType())<0){
	                    examName = getTran("examination",verifiedExaminationVO.examinationId+"",sWebLanguage);
	                    otherExams.put(examName,verifiedExaminationVO);
                    }
                }

                examNames = new Vector(otherExams.keySet());
                Collections.sort(examNames);
                %>
                    <%-- SERVICE HEADER --%>
                    <tr class="list<%=sClass%>" id="otherServiceHeader_<%=serviceId%>" title="<%=showExamsTran%>" onclick="hideAllServiceExaminations('<%=serviceId%>');toggleServiceRow('<%=serviceId%>');" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%-- plus-sign and servicename --%>
                        <td colspan="4">
                            <img id="img_<%=serviceId%>" src="<%=sCONTEXTPATH%>/_img/plus.png" class="link">&nbsp;
                            <%=getTran("Web","service",sWebLanguage)%> <%=getTran("service",serviceId,sWebLanguage)%>
                            (<%=examNames.size()%> <%=getTran("web.manage","examinations",sWebLanguage).toLowerCase()%>)
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <table width="100%" cellpadding="1" cellspacing="0" id="otherServiceExams_<%=serviceId%>" style="display:none;" class="menu">
                            <%
                                if(otherServiceExams.size() > 0){
                            %>
                            <%-- sub-header --%>
                                <tr class="admin">
                                    <td width="400"><%=getTran("web","examination",sWebLanguage)%></td>
                                    <td width="100"/>
                                    <td align="center" width="100"><%=getTran("web","lastexamination",sWebLanguage)%></td>
                                    <td align="center" width="100"><%=getTran("web","planned",sWebLanguage)%></td>
                                    <td/>
                                </tr>
                                <%
                                    // sort other examinations

                                    for(int n=0; n<examNames.size(); n++){
                                        examName = (String)examNames.get(n);
                                        verifiedExaminationVO = (VerifiedExaminationVO)otherExams.get(examName);
                                %>
                                <tr onmouseover="this.className='list_select2';" onmouseout="this.className='';">
                                    <%-- examination name --%>
                                    <td><img src="<c:url value="/_img/pijl.gif"/>"><button class='buttoninvisible'></button> <%=examName%></td>
                                    <%-- create --%>
                                    <td align="center">
                                        <%
                                            if (((verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY"))
                                            &&(checkString(verifiedExaminationVO.getLastExamination()).length()>0))){

                                            }
                                            else if (((verifiedExaminationVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DENTIST"))
                                            &&(checkString(verifiedExaminationVO.getLastExamination()).length()>0))){

                                            }
                                            else {
                                        %>
                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/createTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=defaultContext%>&ts=<%=getTs()%>">
                                            <%=getTran("Web.Occup","medwan.common.new",sWebLanguage)%>
                                        </a>
                                        <%
                                            }
                                        %>
                                    </td>
                                    <%-- edit (last examination date) --%>
                                    <td align="center">
                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
                                            <%=checkString(verifiedExaminationVO.getLastExamination())%>
                                        </a>
                                    </td>
                                    <%-- edit (planned examination date) --%>
                                    <td align="center">
                                        <a onmouseover="window.status='';return true;" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=verifiedExaminationVO.getTransactionType()%>&be.mxs.healthrecord.createTransaction.context=<%=defaultContext%>&be.mxs.healthrecord.transaction_id=<%=verifiedExaminationVO.getLastExaminationId()%>&be.mxs.healthrecord.server_id=<%=verifiedExaminationVO.getLastExaminationServerId()%>&ts=<%=getTs()%>">
                                            <%=checkString(verifiedExaminationVO.getPlannedExaminationDueDateString())%>
                                        </a>
                                    </td>
                                    <td/>
                                </tr>
                                <%
                                    }
                                }
                                else{
                                %>
                                <tr><td colspan="5">&nbsp;<%=getTran("web.manage","nolinkedexaminationsfound",sWebLanguage)%></td></tr>
                                <%
                                }
                                %>
                            </table>
                        </td>
                    </tr>
                <%
            }
        }
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
    %>
    </table>
<script>

  <%-- HIDE ALL SERVICE EXAMINATIONS --%>
  function hideAllServiceExaminations(clickedService){
    var tables = document.getElementsByTagName("table");
    for(var i=0; i<tables.length; i++){
      if(tables[i].id.indexOf("otherServiceExams_") > -1){
        if(tables[i].id != ("otherServiceExams_"+clickedService)){
          tables[i].style.display = "none";
          document.getElementById("img_"+tables[i].id.split("_")[1]).src = "<%=sCONTEXTPATH%>/_img/plus.png";
        }
      }
    }
  }

  <%-- TOGGLE OTHER SERVICES --%>
  function toggleOtherServices(){
    var divObj = document.getElementById("otherServicesTable");

    if(divObj.style.display == "none"){
      divObj.style.display = "";
    }
    else{
      divObj.style.display = "none";
    }
  }

  <%-- TOGGLE SERVICE ROW --%>
  <%
      String showTran = getTranNoLink("web.manage","showExaminations",sWebLanguage),
             hideTran = getTranNoLink("web.manage","hideExaminations",sWebLanguage);
  %>
  function toggleServiceRow(serviceIdx){
    var headerObj = document.getElementById("otherServiceHeader_"+serviceIdx);
    var divObj    = document.getElementById("otherServiceExams_"+serviceIdx);
    var imgObj    = document.getElementById("img_"+serviceIdx);

    if(divObj.style.display == "none"){
      divObj.style.display = "";
      headerObj.title = "<%=hideTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/minus.png";
    }
    else{
      divObj.style.display = "none";
      headerObj.title = "<%=showTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/plus.png";
    }
  }
</script>