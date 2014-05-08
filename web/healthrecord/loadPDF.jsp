<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/pdfmodules.jsp"%>
<%@page import="java.io.*,
                java.text.SimpleDateFormat,
                java.text.DecimalFormat"%>
<%@page import="java.util.Enumeration"%>

<%!
    //--- GET FULL CONTEXT ------------------------------------------------------------------------
    public String getFullContext(javax.servlet.http.HttpServletRequest request){
        return (ScreenHelper.getConfigString("securePorts").indexOf(request.getServerPort() + "") > -1 ? "https://" : "http://") + request.getServerName() + (request.getServerPort() != 80 ? ":" + request.getServerPort() : "") + sCONTEXTPATH;
    }
%>

<%
    try{
        FDFDoc outFDF = new FDFDoc();

        //*** Replace USER parameters ***
        if (activeUser != null){
            outFDF.SetValue("u.fullname",activeUser.person.firstname+" "+activeUser.person.lastname);
            outFDF.SetValue("u.lastname",activeUser.person.lastname);
            outFDF.SetValue("u.firstname",activeUser.person.firstname);
            outFDF.SetValue("u.servicename","");
            outFDF.SetValue("u.address","");
            outFDF.SetValue("u.zipcode","");
            outFDF.SetValue("u.city","");
            outFDF.SetValue("u.phone","");
            outFDF.SetValue("u.fax","");
            outFDF.SetValue("u.email","");
        }
        // no active user
        else {
            outFDF.SetValue("u.fullname","");
            outFDF.SetValue("u.lastname","");
            outFDF.SetValue("u.firstname","");
            outFDF.SetValue("u.servicename","");
            outFDF.SetValue("u.address","");
            outFDF.SetValue("u.zipcode","");
            outFDF.SetValue("u.city","");
            outFDF.SetValue("u.phone","");
            outFDF.SetValue("u.fax","");
            outFDF.SetValue("u.email","");
        }
        //*** Replace PATIENT parameters ***
        if (activePatient != null) {
            outFDF.SetValue("p.fullname",activePatient.lastname+", "+activePatient.firstname);
            outFDF.SetValue("p.lastname",activePatient.lastname+"");
            outFDF.SetValue("p.firstname",activePatient.firstname+"");
            outFDF.SetValue("p.gender",activePatient.gender+"");
            outFDF.SetValue("p.comment",activePatient.comment+"");
            outFDF.SetValue("p.comment1",activePatient.comment1+"");
            outFDF.SetValue("p.comment2",activePatient.comment2+"");
            outFDF.SetValue("p.comment3",activePatient.comment3+"");
            outFDF.SetValue("p.comment4",activePatient.comment4+"");
            outFDF.SetValue("p.comment5",activePatient.comment5+"");
            outFDF.SetValue("p.nationality",activePatient.nativeCountry+"");
            outFDF.SetValue("p.address",activePatient.getActivePrivate().address+"");
            outFDF.SetValue("p.zipcode",activePatient.getActivePrivate().zipcode+"");
            outFDF.SetValue("p.city",activePatient.getActivePrivate().city+"");
            outFDF.SetValue("p.phone",activePatient.getActivePrivate().telephone+"");
            outFDF.SetValue("p.fax",activePatient.getActivePrivate().fax+"");
            outFDF.SetValue("p.email",activePatient.getActivePrivate().email+"");
            outFDF.SetValue("p.immatnew",activePatient.getID("immatnew")+"");
            outFDF.SetValue("p.immatold",activePatient.getID("immatold")+"");
            outFDF.SetValue("p.natreg",activePatient.getID("natreg")+"");
            outFDF.SetValue("p.lang",activePatient.language+"");

            outFDF.SetValue("p.title",getTran("web.userprofile",(activePatient.gender.equalsIgnoreCase("m")?"male_title":"female_title"),(request.getParameter("file").substring(5).startsWith("N")?"NL":"FR")));

            // age
            if (activePatient.dateOfBirth!=null && activePatient.dateOfBirth.length()>0){
                double lAge = ScreenHelper.parseDate(activePatient.dateOfBirth).getTime();
                double lNow = new java.util.Date().getTime();
                double lAgeInSeconds = (lNow-lAge)/1000;
                double fAgeInYears = lAgeInSeconds/(60*60*24*365);

                DecimalFormat decimalFormat = new DecimalFormat();
                decimalFormat.setMaximumFractionDigits(1);
                String sAge = decimalFormat.format(fAgeInYears);
                outFDF.SetValue("p.age",sAge);
            }

            // date of birth
            if(activePatient.dateOfBirth.length() > 0){
                outFDF.SetValue("p.dateofbirth-ddMMyyyy",activePatient.dateOfBirth.replaceAll("/",""));
                outFDF.SetValue("p.dateofbirth-ddMMyy",activePatient.dateOfBirth.replaceAll("/","").substring(0,4)+activePatient.dateOfBirth.replaceAll("/","").substring(6,8));
                outFDF.SetValue("p.dateofbirth",activePatient.dateOfBirth);
            }

            if(activePatient.nativeTown.length() > 0){
                outFDF.SetValue("p.placeofbirth",activePatient.nativeTown);
            }

        }
        // no active person
        else {
            outFDF.SetValue("p.fullname","");
            outFDF.SetValue("p.lastname","");
            outFDF.SetValue("p.firstname","");
            outFDF.SetValue("p.comment","");
            outFDF.SetValue("p.comment1","");
            outFDF.SetValue("p.comment2","");
            outFDF.SetValue("p.comment3","");
            outFDF.SetValue("p.comment4","");
            outFDF.SetValue("p.comment5","");
            outFDF.SetValue("p.nationality","");
            outFDF.SetValue("p.address","");
            outFDF.SetValue("p.zipcode","");
            outFDF.SetValue("p.city","");
            outFDF.SetValue("p.phone","");
            outFDF.SetValue("p.fax","");
            outFDF.SetValue("p.immatnew","");
            outFDF.SetValue("p.natreg","");
            outFDF.SetValue("p.lang","");
            outFDF.SetValue("p.mainservice","");
            outFDF.SetValue("p.dateofbirth-ddMMyyyy","");
            outFDF.SetValue("p.dateofbirth-ddMMyy","");
            outFDF.SetValue("p.dateofbirth","");
            outFDF.SetValue("p.placeofbirth","");
        }

        //*** Replace SYSTEM parameters ***
        SessionContainerWO sessionContainerWO= (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
        if (sessionContainerWO.getCurrentTransactionVO()!=null){
            outFDF.SetValue("s.transactionupdatetime",ScreenHelper.stdDateFormat.format(sessionContainerWO.getCurrentTransactionVO().getUpdateTime()));
        }

        // today
        outFDF.SetValue("today",new SimpleDateFormat("dd MM yyyy").format(new java.util.Date()));
        outFDF.SetValue("todayslash",ScreenHelper.stdDateFormat.format(new java.util.Date()));
        outFDF.SetValue("todayddmmyy",new SimpleDateFormat("dd/MM/yy").format(new java.util.Date()));

        if (session.getAttribute("activeMD")!=null && ((String)session.getAttribute("activeMD")).length()>2){
            outFDF.SetValue("activeMD",(String)session.getAttribute("activeMD"));
            outFDF.SetValue("activeMDMini",((String)session.getAttribute("activeMD")).substring(1,3));
        }

        if (session.getAttribute("activeMedicalCenter")!=null && ((String)session.getAttribute("activeMedicalCenter")).length()>3){
            outFDF.SetValue("activeMedicalCenter",(String)session.getAttribute("activeMedicalCenter"));
        }

        if (session.getAttribute("activePara")!=null && ((String)session.getAttribute("activePara")).length()>2){
            outFDF.SetValue("activePara",(String)session.getAttribute("activePara"));
        }

        //*** Replace parameters that where TRANSMITTED by the calling program ***
        Enumeration enumeration = request.getParameterNames();
        String parName;
        while (enumeration.hasMoreElements()){
            parName = (String)enumeration.nextElement();
            if (parName.indexOf("pdfpar-")>-1){
                // Replace this parameter
                Debug.println("Replacing "+parName+" with "+request.getParameter(parName));
                outFDF.SetValue(parName,request.getParameter(parName));
            }
        }

        //*** Replace parameters that are in a MODULE identified by the calling program ***
        if (request.getParameter("module")!=null){
            session.setAttribute("writer",out);
            includePdfModule(request,outFDF,activePatient,request.getParameter("module"),checkString(request.getParameter("modulepar1")),checkString(request.getParameter("modulepar2")),checkString(request.getParameter("modulepar3")),checkString(request.getParameter("modulepar4")),sWebLanguage);
        }

        if (request.getParameter("id")!=null){
            be.openclinic.system.Document document = be.openclinic.system.Document.getDocumentByID(request.getParameter("id"));

            String sFilename;
            if(document!=null){
                sFilename = document.getFilename();
                String sFile = getFullContext(request)+customerInclude("/documents/"+sFilename.replaceAll("\\\\","/").replaceAll(MedwanQuery.getInstance().getConfigString("DocumentsFolder").replaceAll("\\\\","/"),"").replaceAll("//","/"));
                Debug.println(sFile);
                Debug.println("Looking via id for '"+sFile+"'");
                outFDF.SetFile(sFile);
            }
        }
        else if (request.getParameter("file")!=null){
            String sFileName = getFullContext(request)+customerInclude("/documents/"+request.getParameter("file")).replaceAll("//","/");

            Debug.println("Looking via filename for '"+sFileName+"'");
            outFDF.SetFile(sFileName);
        }

        String sFDFFile = (MedwanQuery.getInstance().getConfigString("DocumentsFolder")+"/"+activeUser.userid+".fdf").replaceAll("//","/");
        OutputStream outs = new FileOutputStream(sFDFFile);
        outFDF.Save(outs);
        outs.close();

        %>
            <script>
                window.location.href = '<%=getFullContext(request)+"/util/showpdf.jsp?FDFFile="+getFullContext(request)+customerInclude("/documents/"+activeUser.userid+".fdf").replaceAll("//","/")+"&PDFFile="+outFDF.GetFile()+"&ts="+getTs()%>';
              //window.location.href = '<%=getFullContext(request)+"/util/showpdf.jsp?FDFFile="+sFDFFile+"&PDFFile="+outFDF.GetFile()+"&ts="+getTs()%>';
            </script>
        <%
    }
    catch(Exception e){
        e.printStackTrace();
    }
%>