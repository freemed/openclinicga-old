<%@page import="com.adobe.fdf.FDFDoc,
                java.text.MessageFormat"%>

<%!
    //### INCLUDE PDF MODULE ######################################################################
    public void includePdfModule(javax.servlet.http.HttpServletRequest request, FDFDoc outFDF, AdminPerson activePatient,
                                 String module, String modulepar1, String modulepar2, String modulepar3, String modulepar4, String sWebLanguage) {
        try {
            // TODO this is just an example !!!!!
            //--- xx_46 ---------------------------------------------------------------------------
            if (module.equalsIgnoreCase("xx_46")) {
                // date of birth
                if (activePatient.dateOfBirth.length() > 0) {
                    Object[] charArray = activePatient.dateOfBirth.split("");
                    String sDOBFormatted = MessageFormat.format("{1} {2} {4} {5} {9} {10}", charArray);
                    outFDF.SetValue("p.dateofbirth-formatted", sDOBFormatted);
                }
                
                // naam
                String sLastName = activePatient.lastname;
                if (sLastName.length() > 0) {
                    Object[] charArray = sLastName.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sLastName = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.lastname", sLastName);
                }

                // voornaam
                String sFirstName = activePatient.firstname;
                if (sFirstName.length() > 0) {
                    Object[] charArray = sFirstName.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sFirstName = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.firstname", sFirstName);
                }

                // address
                String sAddress = activePatient.getActivePrivate().address;
                if (sAddress.length() > 0) {
                    Object[] charArray = sAddress.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sAddress = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.address", sAddress);
                }

                // city
                String sCity = activePatient.getActivePrivate().city;
                if (sCity.length() > 0) {
                    Object[] charArray = sCity.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sCity = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.city", sCity);
                }

                // zipcode
                String sZipcode = activePatient.getActivePrivate().zipcode;
                if (sZipcode.length() > 0) {
                    Object[] charArray = sZipcode.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sZipcode = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.zipcode", sZipcode);
                }

                // telephone
                String sTelephone = activePatient.getActivePrivate().telephone;
                if (sTelephone.length() > 0) {
                    Object[] charArray = sTelephone.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sTelephone = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.phone", sTelephone);
                }

                // national register number
                String sNatreg = activePatient.getID("natreg");
                if (sNatreg.length() > 0) {
                    Object[] charArray = sNatreg.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sNatreg = MessageFormat.format(charLayout, charArray);
                    outFDF.SetValue("p.natreg-formatted", sNatreg);
                }

                // language - full
                String sLanguage = activePatient.language;
                if (sLanguage.length() > 0) {
                    // transform language code
                    if (sLanguage.equalsIgnoreCase("n")) sLanguage = "nl";
                    else if (sLanguage.equalsIgnoreCase("f")) sLanguage = "fr";
                    else if (sLanguage.equalsIgnoreCase("d")) sLanguage = "de";

                    // translate language
                    sLanguage = getTran("web.language", sLanguage, sWebLanguage);

                    Object[] charArray = sLanguage.split("");
                    String charLayout = "";
                    for (int i = 1; i < charArray.length; i++) charLayout += "{" + i + "} ";
                    sLanguage = MessageFormat.format(charLayout, charArray);

                    outFDF.SetValue("p.lang-formatted", sLanguage);
                }

                // gender
                if (activePatient.gender.length() > 0) {
                    outFDF.SetValue("p.gender", activePatient.gender.toLowerCase());
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
%>