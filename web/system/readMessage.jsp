<%@page import="be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,
                java.util.*,
                javazoom.upload.MultipartFormDataRequest,
                javazoom.upload.UploadFile,
                java.io.*,be.mxs.common.util.system.Mail"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<%!
    private SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    private boolean writeEmail(MessageReader.Document document,BufferedWriter writer,MessageReader.User user) throws java.io.IOException {
        String sText = "";
        String sColor = "white";
        String label = "FR";
        if (user.language.equalsIgnoreCase("N")){
            label = "NL";
        }

        MessageReader.Item item;
        for (int n=0; n<document.transaction.items.size(); n++){
            item = (MessageReader.Item)document.transaction.items.elementAt(n);
            if (item.normal!=MessageReader.N){
                sText+="<tr bgcolor='"+sColor+"'><td>"+item.name.get(label)+"</td><td>"+item.unitname.get(label)+"</td><td>"+item.normal+"</td><td colspan='2'>"+item.modifier+item.result+"</td><td>"+item.comment+"</td></tr>";
                if (sColor.equalsIgnoreCase("white")){
                    sColor = "lightgrey";
                }
                else {
                    sColor = "white";
                }
            }
        }

        if (sText.length()==0){
            sText+="<tr bgcolor='"+sColor+"'>"+
                   "<td colspan='5'>"+getTran("web.occup","medwan.common.negative",user.language)+"</td>"+
                   "</tr>";
        }

        sText="<td><b>"+stdDateFormat.format(document.transaction.requestdate)+"</b></td><td>"+"</td></tr>"+sText;
        sText="<tr bgcolor='peachpuff'><td><b>"+document.patient.firstname+" "+document.patient.lastname+"</b></td><td><b>"+MedwanQuery.getInstance().getImmatnew(document.patient.personid)+"</b></td><td>°"+stdDateFormat.format(document.patient.dateofbirth)+"</td><td>"+document.patient.gender+"</td>"+sText;
        sText+="<tr><td colspan='5'><hr/></td></tr>";
        writer.write(sText);

        return true;
    }
%>
<script>window.clearInterval(userinterval);</script>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value="<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp") %>" />
    <jsp:setProperty name="upBean" property="parser" value="<%= MultipartFormDataRequest.CFUPARSER %>"/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value="<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp") %>"/>
</jsp:useBean>
<script>
  function setGreen(theItem,theButton){
    document.getElementsByName(theItem)[0].className = 'green';
    theButton.className = 'buttonhidden';
  }

  function doSubmit(){
    if (readMessageForm.filename.value.length>0){
      readMessageForm.readfile.value = 'ok';
      readMessageForm.submit();
    }
  }
</script>
<form name="readMessageForm" method="POST" enctype="multipart/form-data">
    <%=writeTableHeader("Web.Occup","medwan.common.messages",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table width="100%" class="list" cellspacing="1">
        <%-- MESSAGE TYPE --%>
        <tr>
            <td class="admin"><%=getTran("Web.Result","message_type",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="fileformat">
                    <option name="medidoc" value="MEDIDOC">MEDIDOC</option>
                </select>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="checkbox" id="createUnknown" name="createUnknown"/><%=getLabel("Web.Result","create_unknown_patients",sWebLanguage,"createUnknown")%>
            </td>
            <td class="admin2"/>
        </tr>
        <%-- MESSAGE FILE --%>
        <tr>
            <td class="admin"><%=getTran("Web.Result","message_file",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input class="text" type="file" name="filename"/>
                <input class="button" type="button" name="ButtonReadfile" value="<%=getTran("Web.Result","read_message",sWebLanguage)%>" onclick="doSubmit()"/>
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="cancel" value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick='javascript:window.location.href="main.do?Page=system/menu.jsp"'>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <input type="hidden" name="readfile">
<%
    String sFileName = "";
    MultipartFormDataRequest mrequest;
    if (MultipartFormDataRequest.isMultipartFormData(request)) {
      // Uses MultipartFormDataRequest to parse the HTTP request.
      mrequest = new MultipartFormDataRequest(request);

      if (mrequest.getParameter("readfile")!=null){

        %>
            <table width="100%" class="list" cellspacing="1">
        <%
        if (mrequest.getParameter("integrate")==null){
            try{
                Hashtable files = mrequest.getFiles();
                if (files != null && !files.isEmpty()){
                    UploadFile file = (UploadFile) files.get("filename");
                    sFileName= new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new java.util.Date())+".ext";
                    file.setFileName(sFileName);
                    upBean.store(mrequest, "filename");
                    MessageReaderMedidoc messageReader=new MessageReaderMedidoc(upBean.getFolderstore()+"/"+sFileName);
                    status(out,"Reading file "+sFileName+"...");
                    messageReader.process();
                    status(out,"Identifying patients...");
                    messageReader.identify();
                    status(out,"Done");
                    session.setAttribute("activeMessage",messageReader);
                    File f = new File(upBean.getFolderstore()+"/"+sFileName);
                    f.delete();
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        if (session.getAttribute("activeMessage")!=null){
            MessageReader messageReader = (MessageReader)session.getAttribute("activeMessage");
            if ((mrequest.getParameter("readfile")==null || mrequest.getParameter("readfile").length()==0) && mrequest.getParameterNames().hasMoreElements()){
//            if (mrequest.getParameterNames().hasMoreElements()){
                //First do any requested updates
                Enumeration names = mrequest.getParameterNames();
                String name;
                while (names.hasMoreElements()){
                    name = (String)names.nextElement();
                    if (mrequest.getParameter(name)!=null && mrequest.getParameter(name).length()>0){
                        if (name.equals("user")){
                            messageReader.user.userid=Integer.parseInt(mrequest.getParameter(name));
                            messageReader.user.update = MessageReader.YES;
                            messageReader.user.update();
                        }
                        if (name.startsWith("patient")){
                            int index = Integer.parseInt(name.substring(7));
                            ((MessageReader.Document)messageReader.documents.get(index)).patient.personid=Integer.parseInt(mrequest.getParameter(name));
                        }
                    }
                }
            }

            if (mrequest.getParameter("integrate")!=null){
                boolean dataExists=false;
                //We will write all abnormal values to a temporary file. This file is to be sent to the prescribing physician
                String sTempDir = "";
                if(MedwanQuery.getInstance().getConfigString("tempDirectory").length() > 0){
                    sTempDir = MedwanQuery.getInstance().getConfigString("tempDirectory");
                }
                String shortFileName = new SimpleDateFormat("ddMMyyyyHHmmssSSS").format(new java.util.Date())+".html";
                String sTempFileName = (sTempDir+"/").replaceAll("//","/")+shortFileName;
                FileWriter fileWriter = new FileWriter(sTempFileName);
                BufferedWriter emailWriter = new BufferedWriter(fileWriter);
                emailWriter.write("<table style='font-family: arial;font-size: 10px;'>");

                //Only data from identified persons will be stored
                Iterator iterator = messageReader.documents.iterator();
                MessageReader.Document document;
                MessageReader.Patient patient;
                AdminPerson adminPerson;
                AdminPrivateContact contact;

                while (iterator.hasNext()){
                    document = (MessageReader.Document)iterator.next();
                    patient = document.patient;
                    if (patient.personid!=-1){
                        status(out,"Processing document dd "+stdDateFormat.format(document.transaction.requestdate)+" for "+patient.firstname+" "+patient.lastname+"...");
                        if (document.store()==MessageReader.OK){
                            document.status=MessageReader.TO_BE_REMOVED;
                            if (document.newdata==MessageReader.YES){
                                dataExists = writeEmail(document,emailWriter,messageReader.user)|| dataExists;
                            }
                        }
                    }
                    else {
                        //check if we need to create unidentified persons
                        if (mrequest.getParameter("createUnknown")!=null){
                            status(out,"Creating record for "+patient.firstname+" "+patient.lastname+"...");
                            adminPerson = new AdminPerson();
                            adminPerson.ids.add(new AdminID("natreg",patient.natreg));
                            adminPerson.ids.add(new AdminID("immatnew",patient.id));
                            adminPerson.lastname=patient.lastname;
                            adminPerson.firstname=patient.firstname;
                            adminPerson.dateOfBirth=stdDateFormat.format(patient.dateofbirth);
                            adminPerson.gender=patient.gender;
                            contact = new AdminPrivateContact();
                            contact.begin=stdDateFormat.format(new java.util.Date());
                            contact.address=patient.address;
                            contact.zipcode=patient.zipcode;
                            contact.city=patient.city;
                            adminPerson.privateContacts.add(contact);
                            adminPerson.sourceid=MedwanQuery.getInstance().getConfigString("PatientEditSourceID");
                          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                            adminPerson.saveToDB(ad_conn,checkString((String)session.getAttribute("activeMedicalCenter")),checkString((String)session.getAttribute("activeMD")),checkString((String)session.getAttribute("activePara")));
                            ad_conn.close();
                            patient.personid=Integer.parseInt(adminPerson.personid);

                            status(out,"Processing document dd "+stdDateFormat.format(document.transaction.requestdate)+" for "+patient.firstname+" "+patient.lastname+"...");
                            if (document.store()==MessageReader.OK){
                                document.status=MessageReader.TO_BE_REMOVED;
                                dataExists = writeEmail(document,emailWriter,messageReader.user)|| dataExists;
                            }
                        }
                    }
                }

                boolean bContinue = true;
                while (bContinue){
                    bContinue = false;
                    iterator = messageReader.documents.iterator();
                    while (iterator.hasNext()){
                        document = (MessageReader.Document)iterator.next();
                        if (document.status==MessageReader.TO_BE_REMOVED){
                            messageReader.documents.remove(document);
                            bContinue=true;
                            break;
                        }
                    }
                }
                reloadSingleton(session);
                emailWriter.write("</table>");
                emailWriter.flush();
                emailWriter.close();
                fileWriter.close();

                if (dataExists){
                    //There was some data to be transmitted to the prescribing physician
                    //Transmit it now
                    try {
                        String sMessage = getTran("Web.Occup","medwan.lab.reflab",sWebLanguage)+": "+messageReader.lab.name+"\n";
                        sMessage += getTran("Web.result","date",sWebLanguage)+": "+stdDateFormat.format(messageReader.fileDate)+"\n";
                        sMessage += getTran("Web.Occup","medwan.common.abnormal-in-attachment",sWebLanguage);

                        if (MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer").length() > 0 && MedwanQuery.getInstance().getConfigString("PatientEdit.MailSender").length() > 0 && messageReader.user.email!=null){
                            User user = new User();
                            user.initialize(messageReader.user.userid);
                            status(out,"Sending e-mail to "+messageReader.user.email+"...");
                            Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"),MedwanQuery.getInstance().getConfigString("PatientEdit.MailSender"),messageReader.user.email,getTran("Web.result","labresult",sWebLanguage),sMessage,sTempFileName,shortFileName);
                        }

                        File f = new File(sTempFileName);
                        f.delete();
                    }
                    catch (Exception e){
                        // nothing
                    }
                }
                else {
                    File f = new File(sTempFileName);
                    f.delete();
                }
            }

            //Print referring lab header
            out.print("<tr><td class='menuItem'>"+getTran("Web.Result","referring_lab",sWebLanguage)+"</td><td class='text' colspan='3'>"+messageReader.lab.name+"</td></tr>");

            //Print message header
            out.print("<tr><td class='menuItem'>"+getTran("Web.Result","message_date",sWebLanguage)+"</td><td class='text' colspan='3'>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(messageReader.fileDate)+"</td></tr>");
            out.print("<tr><td class='menuItem'>"+getTran("Web.Result","message_file",sWebLanguage)+"</td><td class='text' colspan='3'>"+messageReader.fileName+"</td></tr>");

            //Print user header
            if (messageReader.user.userid==-1){
                out.print("<tr id='idUser' class='red'><td class='menuItem'>"+getTran("Web.Result","user_id",sWebLanguage)+"</td><td>"+messageReader.user.firstname+" "+messageReader.user.lastname+"</td><td colspan='2'>"+messageReader.user.RIZIV+"</td>");
                out.print("<td><input type='hidden' name='user' onchange='setGreen(\"idUser\",bUser);'/>");
                %>
                    <input class='button' type='button' name='bUser' value='<%=getTran("Web","Select",sWebLanguage)%>'
                    onclick='window.open("<c:url value="/popup.jsp"/>?Page=_common/search/searchPatient.jsp&ts=<%=getTs()%>&SetGreenField=idUser&ReturnPersonID=user&isUser=yes&FindFirstname=<%=messageReader.user.firstname%>&FindLastname=<%=messageReader.user.lastname%>"
                    ,"<%=getTran("Web","Find",sWebLanguage)%>","toolbar=no, status=no, scrollbars=yes, resizable=yes, menubar=no");'>
                <%
            }
            else {
                out.print("<tr id='idUser' class='green'><td class='menuItem'>"+getTran("Web.Result","user_id",sWebLanguage)+"</td><td>"+messageReader.user.firstname+" "+messageReader.user.lastname+"</td><td colspan='2'>"+messageReader.user.RIZIV+"</td>");
                out.print("<td>&nbsp;</td></tr>");
            }
            out.print("<tr><td colspan='5'><hr></td></tr>");

            //Print patient headers
            MessageReader.Document document;
            MessageReader.Transaction transaction;
            MessageReader.Patient patient;
            String warning;
            MessageReader.Item item;
            MessageReader.Patient alternatePatient;
            String bgcolor;
            AdminPerson alternatePerson;

            for (int n=0;n<messageReader.documents.size();n++){
                document = (MessageReader.Document)messageReader.documents.get(n);
                transaction = document.transaction;
                patient = document.patient;

                //Test if there are any abnormal values
                warning="";
                for (int i=0;i<transaction.items.size();i++){
                    item = (MessageReader.Item)transaction.items.get(i);
                    if ((item.type.equals(MessageReader.TYPE_NUMERIC) || item.type.equals(MessageReader.TYPE_DAYS)||item.type.equals(MessageReader.TYPE_HOURS)||item.type.equals(MessageReader.TYPE_MINUTES)||item.type.equals(MessageReader.TYPE_SECONDS)) && !item.normal.equals(MessageReader.N)){
                        warning="&nbsp;<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>";
                        break;
                    }
                }

              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                if (patient.personid==-1){
                    out.print("<tr id='idPatient"+n+"' class='red'><td class='menuItem'>"+getTran("Web.Result","patient_id",sWebLanguage)+"</td><td>"+patient.firstname+" "+patient.lastname+warning+"</td><td>"+stdDateFormat.format(patient.dateofbirth)+"</td><td>"+patient.gender+"</td>");
                    out.print("<td><input type='hidden' name='patient"+n+"' onchange='setGreen(\"idPatient"+n+"\",bPatient"+n+");'/>");

                    %>
                        <input class='button' type='button' name='bPatient<%=n%>' value='<%=getTran("Web","Select",sWebLanguage)%>'
                        onclick='window.open("<c:url value="/popup.jsp"/>?Page=_common/search/searchPatient.jsp&ts=<%=getTs()%>&SetGreenField=idPatient<%=n%>&ReturnPersonID=patient<%=n%>&FindFirstname=<%=patient.firstname%>&FindLastname=<%=patient.lastname%>"
                        ,"<%=getTran("Web","Find",sWebLanguage)%>","toolbar=no, status=no, scrollbars=yes, resizable=yes, menubar=no");'>
                    <%

                    for (int i=0;i<patient.alternatePatients.size();i++){
                        alternatePatient = (MessageReader.Patient)patient.alternatePatients.elementAt(i);
                        alternatePerson = new AdminPerson();
                        alternatePerson.initialize(ad_conn, Integer.toString(alternatePatient.personid));
                        out.print("<tr class='red' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"' onclick='document.getElementsByName(\"patient"+n+"\")[0].value="+alternatePatient.personid+";setGreen(\"idPatient"+n+"\",bPatient"+n+");'><td class='menuItem'>&nbsp;</td><td><img src='"+sCONTEXTPATH+"/_img/arrow_right.gif'/> "+alternatePatient.firstname+" "+alternatePatient.lastname+" "+checkString(alternatePerson.getID("immatnew"))+"</td><td>"+stdDateFormat.format(alternatePatient.dateofbirth)+"</td><td>"+alternatePatient.gender+"</td></tr>");
                    }
                }
                else {
                    alternatePerson = new AdminPerson();
                    alternatePerson.initialize(ad_conn, Integer.toString(patient.personid));
                    out.print("<tr id='idPatient"+n+"' class='green'><td class='menuItem'>"+getTran("Web.Result","patient_id",sWebLanguage)+"</td><td>"+patient.firstname+" "+patient.lastname+" "+checkString(alternatePerson.getID("immatnew"))+" "+warning+"</td><td>"+stdDateFormat.format(patient.dateofbirth)+"</td><td>"+patient.gender+"</td>");
                    out.print("<td>&nbsp;</td></tr>");
                }
				ad_conn.close();
                if (!warning.equals("")){
                    bgcolor = "lightyellow";
                    for (int i=0;i<transaction.items.size();i++){
                        item = (MessageReader.Item)transaction.items.get(i);
                        if ((item.type.equals(MessageReader.TYPE_NUMERIC) || item.type.equals(MessageReader.TYPE_DAYS)||item.type.equals(MessageReader.TYPE_HOURS)||item.type.equals(MessageReader.TYPE_MINUTES)||item.type.equals(MessageReader.TYPE_SECONDS)) && !item.normal.equals(MessageReader.N)){
                            out.print("<tr><td/><td bgcolor='"+bgcolor+"' class='text'>"+item.name.get("NL")+"</td><td bgcolor='"+bgcolor+"' class='text'>"+item.modifier+item.result+"</td><td bgcolor='"+bgcolor+"' class='text'>"+item.unitname.get("NL")+"</td><td bgcolor='"+bgcolor+"' class='text'>"+item.normal+"</td></tr>");
                            if (bgcolor.equals("lightyellow")){
                                bgcolor = "white";
                            }
                            else {
                                bgcolor = "lightyellow";
                            }
                        }
                    }
                }
            }
        }
        %>
    </table>
        <%
      }
    }
%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    if (sFileName.length()>0){%>
        <input type="submit" class="button" name="integrate" value="<%=getTran("Web.Result","integrate_messages",sWebLanguage)%>"/>
        <p align="right">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </p>
<%
    }
%>
<%=ScreenHelper.alignButtonsStop()%>
</form>