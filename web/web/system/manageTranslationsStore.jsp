<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>
<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";

    String tmpLang;
    Hashtable hTranslations = new Hashtable();
    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
    while (tokenizer.hasMoreTokens()) {
        tmpLang = tokenizer.nextToken();
        hTranslations.put(tmpLang.toUpperCase(),checkString(request.getParameter("EditLabelValue"+tmpLang.toUpperCase())).replaceAll("<BR>","\n"));
    }

    String sAction = checkString(request.getParameter("Action"));

    // get values from form

    String editLabelID = checkString(request.getParameter("EditLabelID")).toLowerCase(),
            editLabelType = checkString(request.getParameter("EditLabelType")).toLowerCase();

    String editOldLabelID = checkString(request.getParameter("EditOldLabelID")).toLowerCase(),
            editOldLabelType = checkString(request.getParameter("EditOldLabelType")).toLowerCase();

    String editShowLink = checkString(request.getParameter("EditShowLink"));

    boolean invalidCharFound;
    boolean bExists = false;
    String msg = getTran("web.manage", "labelsaved", sWebLanguage);

    if (sAction.equals("Save")) {
        // invalid key chars
        String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
        if (invalidLabelKeyChars.length() == 0) {
            invalidLabelKeyChars = " /:"; // default
        }

        // check label type and id for invalid chars
        invalidCharFound = false;
        for (int i = 0; i < invalidLabelKeyChars.length(); i++) {
            if ((editLabelType + editLabelID).indexOf(invalidLabelKeyChars.charAt(i)) > -1) {
                invalidCharFound = true;
                msg = getTran("Web.manage", "invalidcharsfound", sWebLanguage) + " '" + invalidLabelKeyChars + "'";
                break;
            }
        }

        if (!invalidCharFound) {
            // check existence
            tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                Label oldLabel = new Label();
                oldLabel.type = editOldLabelType;
                oldLabel.id = editOldLabelID;
                oldLabel.language = tmpLang;

                if (oldLabel.exists()) bExists = true;

                if (bExists) {
                    Label label = new Label();
                    label.type = editLabelType;
                    label.id = editLabelID;
                    label.language = tmpLang;
                    label.value = checkString((String)hTranslations.get(tmpLang.toUpperCase()));
                    label.updateUserId = activeUser.userid;
                    label.showLink = editShowLink;

                    label.updateByTypeIdLanguage(editOldLabelType, editOldLabelID, tmpLang);

                    editOldLabelID = editLabelID;
                    editOldLabelType = editLabelType;
                }
            }
            reloadSingleton(session);

            msg = "'" + editLabelType + "$" + editLabelID+ "$" + checkString((String)hTranslations.get(sWebLanguage.toUpperCase())) + "' " + getTran("Web", "saved", sWebLanguage);
        }
    }

    //*** ADD *************************************************************************************
    if (sAction.equals("Add")) {
        // invalid key chars
        String invalidLabelKeyChars = MedwanQuery.getInstance().getConfigString("invalidLabelKeyChars");
        if (invalidLabelKeyChars.length() == 0) {
            invalidLabelKeyChars = " /:"; // default
        }

        // check label type and id for invalid chars
        invalidCharFound = false;
        for (int i = 0; i < invalidLabelKeyChars.length(); i++) {
            if ((editLabelType + editLabelID).indexOf(invalidLabelKeyChars.charAt(i)) > -1) {
                invalidCharFound = true;
                msg = getTran("Web.manage", "invalidcharsfound", sWebLanguage) + " '" + invalidLabelKeyChars + "'";
                break;
            }
        }

        if (!invalidCharFound) {
            // exists ?
            boolean labelExists;
            tokenizer = new StringTokenizer(supportedLanguages, ",");
            while (tokenizer.hasMoreTokens()) {
                tmpLang = tokenizer.nextToken();

                Label label = new Label();
                label.id = editLabelID;
                label.type = editLabelType;
                label.language = tmpLang;
                label.showLink = editShowLink;
                label.value = checkString((String)hTranslations.get(tmpLang.toUpperCase()));
                label.updateUserId = activeUser.userid;
                labelExists = label.exists();

                // INSERT
                if (!labelExists) {
                    label.saveToDB();

                    msg = "'" + editLabelType + "$" + editLabelID + "$" + checkString((String)hTranslations.get(sWebLanguage.toUpperCase())) + "' " + getTran("Web", "added", sWebLanguage);

                } else {
                    // a label with the given ids allready exists
                    msg = getTran("Web.Manage", "labelExists", sWebLanguage);
                }
            }
            editOldLabelID = editLabelID;
            editOldLabelType = editLabelType;

            reloadSingleton(session);
        }
    }
    //*** DELETE **********************************************************************************
    else if (sAction.equals("Delete")) {
        tokenizer = new StringTokenizer(supportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();

            Label.delete(editLabelType, editLabelID, tmpLang);
        }
        msg = "'" + editLabelType + "$" + editLabelID + "$" + checkString((String)hTranslations.get(sWebLanguage.toUpperCase())) + "' " + getTran("Web", "deleted", sWebLanguage);
    }

    out.print(HTMLEntities.htmlentities(msg));
%>
