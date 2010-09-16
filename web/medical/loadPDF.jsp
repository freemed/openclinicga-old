<%@include file="/includes/pdfmodules.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="com.adobe.fdf.*,
                com.adobe.fdf.exceptions.*,
                java.io.*,
                java.util.*,
                java.text.SimpleDateFormat,
                java.text.DecimalFormat"%>

<%!
    //--- GET FULL CONTEXT ------------------------------------------------------------------------
    public String getFullContext(javax.servlet.http.HttpServletRequest request){
        return (ScreenHelper.getConfigString("securePorts").indexOf(request.getServerPort() + "") > -1 ? "https://" : "http://") + request.getServerName() + (request.getServerPort() != 80 ? ":" + request.getServerPort() : "") + sCONTEXTPATH;
    }
%>

<%
   	FDFDoc outFDF = new FDFDoc();

    try{
        //*** Replace USER parameters *****************************************
        if(activeUser != null){
            outFDF.SetValue("p.fullname",activeUser.person.lastname+", "+activeUser.person.firstname);
            outFDF.SetValue("u.lastname",activeUser.person.lastname);
            outFDF.SetValue("u.firstname",activeUser.person.firstname);

            // service data
            outFDF.SetValue("u.servicename",getTranNoLink("service",activeUser.activeService.code,sWebLanguage));
            outFDF.SetValue("u.address",activeUser.activeService.address);
            outFDF.SetValue("u.zipcode",activeUser.activeService.zipcode);
            outFDF.SetValue("u.city",activeUser.activeService.city);
            outFDF.SetValue("u.phone",activeUser.activeService.telephone);
            outFDF.SetValue("u.fax",activeUser.activeService.fax);
            outFDF.SetValue("u.email",activeUser.activeService.email);
        }
        // no active user
        else{
            outFDF.SetValue("u.fullname","");
            outFDF.SetValue("u.lastname","");
            outFDF.SetValue("u.firstname","");

            // service data
            outFDF.SetValue("u.servicename","");
            outFDF.SetValue("u.address","");
            outFDF.SetValue("u.zipcode","");
            outFDF.SetValue("u.city","");
            outFDF.SetValue("u.phone","");
            outFDF.SetValue("u.fax","");
            outFDF.SetValue("u.email","");
        }

        //*** Replace PATIENT parameters **************************************
        if(activePatient != null){
            outFDF.SetValue("p.fullname",activePatient.lastname+", "+activePatient.firstname);
            outFDF.SetValue("p.lastname",activePatient.lastname+"");
            outFDF.SetValue("p.firstname",activePatient.firstname+"");
            outFDF.SetValue("p.personid",activePatient.personid+"");

            outFDF.SetValue("p.comment",activePatient.comment);
            outFDF.SetValue("p.comment1",activePatient.comment1);
            outFDF.SetValue("p.comment2",activePatient.comment2);
            outFDF.SetValue("p.comment3",activePatient.comment3);
            outFDF.SetValue("p.comment4",activePatient.comment4);
            outFDF.SetValue("p.comment5",activePatient.comment5);

            outFDF.SetValue("p.nationality",activePatient.nativeCountry+"");
            outFDF.SetValue("p.address",activePatient.getActivePrivate().address+"");
            outFDF.SetValue("p.zipcode",activePatient.getActivePrivate().zipcode+"");
            outFDF.SetValue("p.city",activePatient.getActivePrivate().city+"");
            outFDF.SetValue("p.phone",activePatient.getActivePrivate().telephone+"");
            outFDF.SetValue("p.fax",activePatient.getActivePrivate().fax+"");
            outFDF.SetValue("p.email",activePatient.getActivePrivate().email+"");
            outFDF.SetValue("p.immatnew",activePatient.getID("immatnew")+"");
            outFDF.SetValue("p.natreg",activePatient.getID("natreg")+"");
            outFDF.SetValue("p.lang",activePatient.language+"");

            outFDF.SetValue("p.title",getTran("web.userprofile",(activePatient.gender.equalsIgnoreCase("m")?"male_title":"female_title"),(request.getParameter("file").substring(5).startsWith("N")?"N":"F")));

            // date of birth
            if (activePatient.dateOfBirth!=null && activePatient.dateOfBirth.length()>0){
                double lAge = new SimpleDateFormat("dd/MM/yyyy").parse(activePatient.dateOfBirth).getTime();
                double lNow = new java.util.Date().getTime();
                double lAgeInSeconds = (lNow-lAge)/1000;
                double fAgeInYears = lAgeInSeconds/(60*60*24*365);

                DecimalFormat decimalFormat = new DecimalFormat();
                decimalFormat.setMaximumFractionDigits(1);
                String sAge = decimalFormat.format(fAgeInYears);
                outFDF.SetValue("p.age",sAge);
            }

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

            outFDF.SetValue("p.title","");
            outFDF.SetValue("p.age","");
            outFDF.SetValue("p.dateofbirth-ddMMyyyy","");
            outFDF.SetValue("p.dateofbirth-ddMMyy","");
            outFDF.SetValue("p.dateofbirth","");
            outFDF.SetValue("p.placeofbirth","");
        }

        //*** Replace SYSTEM parameters ***************************************
        SessionContainerWO sessionContainerWO= (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
        if (sessionContainerWO.getCurrentTransactionVO()!=null){
            outFDF.SetValue("s.transactionupdatetime",new SimpleDateFormat("dd/MM/yyyy").format(sessionContainerWO.getCurrentTransactionVO().getUpdateTime()));
        }

        outFDF.SetValue("s.today",new SimpleDateFormat("dd MM yyyy").format(new java.util.Date()));
        outFDF.SetValue("s.todayslash",new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));
        outFDF.SetValue("s.todayddmmyy",new SimpleDateFormat("dd/MM/yy").format(new java.util.Date()));

        if (session.getAttribute("activeMD")!=null && ((String)session.getAttribute("activeMD")).length()>2){
            outFDF.SetValue("s.activeMD",(String)session.getAttribute("activeMD"));
            outFDF.SetValue("s.activeMDMini",((String)session.getAttribute("activeMD")).substring(1,3));
        }

        if (session.getAttribute("activeMedicalCenter")!=null && ((String)session.getAttribute("activeMedicalCenter")).length()>3){
            outFDF.SetValue("s.activeMedicalCenter",(String)session.getAttribute("activeMedicalCenter"));
        }

        if (session.getAttribute("activePara")!=null && ((String)session.getAttribute("activePara")).length()>2){
            outFDF.SetValue("s.activePara",(String)session.getAttribute("activePara"));
        }

        //*** Replace PARAMETERS TRANSMITTED by the calling page **************
        Enumeration enumeration = request.getParameterNames();
        String parName;
        while (enumeration.hasMoreElements()){
            parName = (String)enumeration.nextElement();
            if (parName.indexOf("pdfpar-")>-1){
                outFDF.SetValue(parName,request.getParameter(parName));
            }
        }

        //*** Replace PARAMETERS in MODULE specified by the calling page ******
        if (request.getParameter("module")!=null){
            session.setAttribute("writer",out);
            includePdfModule(request,outFDF,activePatient,
                             request.getParameter("module"),
                             checkString(request.getParameter("modulepar1")),
                             checkString(request.getParameter("modulepar2")),
                             checkString(request.getParameter("modulepar3")),
                             checkString(request.getParameter("modulepar4")),sWebLanguage);
        }
        String sPDFFile="";
        if (request.getParameter("id")!=null){
           	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            PreparedStatement ps = ad_conn.prepareStatement("select * from Documents where id=?");
            ps.setString(1,request.getParameter("id"));
            ResultSet rs = ps.executeQuery();

            if (rs.next()){
                String sFile = getFullContext(request)+customerInclude("/documents/"+rs.getString("filename").replaceAll("\\\\","/").replaceAll(MedwanQuery.getInstance().getConfigString("DocumentsFolder").replaceAll("\\\\","/"),"").replaceAll("//","/"));
                if(Debug.enabled) Debug.println(sFile);
                if(Debug.enabled) Debug.println("Looking via id for '"+sFile+"'");
                outFDF.SetFile(sFile);
                sPDFFile=sFile;
            }

            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
            ad_conn.close();
        }
        else if (request.getParameter("file")!=null){
            String sFileName = getFullContext(request)+customerInclude("/documents/"+request.getParameter("file")).replaceAll("//","/");

            if(Debug.enabled) Debug.println("Looking via filename for '"+sFileName+"'");
            outFDF.SetFile(sFileName);
            sPDFFile=sFileName;
        }

        String sFDFFile = (MedwanQuery.getInstance().getConfigString("DocumentsFolder","c:/projects/openclinic/documents")+"/"+activeUser.userid+".fdf").replaceAll("//","/");
        OutputStream outs = new FileOutputStream(sFDFFile);
        outFDF.Save(outs);
        outs.close();

        %>
            <script>
              window.location.href = '<%=getFullContext(request)+"/util/showpdf.jsp?FDFFile="+getFullContext(request)+customerInclude("/documents/"+activeUser.userid+".fdf").replaceAll("//","/")+"&PDFFile="+sPDFFile+"&ts="+getTs()%>';
            </script>
        <%
    }
    catch(Exception e){
        e.printStackTrace();
    }
%>