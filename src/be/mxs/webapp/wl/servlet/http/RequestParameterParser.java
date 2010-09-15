package be.mxs.webapp.wl.servlet.http;

import javax.servlet.http.HttpServletRequest;
import java.util.Hashtable;
import java.util.Enumeration;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-juil.-2003
 * Time: 13:41:42
 * To change this template use Options | File Templates.
 */
public class RequestParameterParser {

    private static RequestParameterParser requestParameterParser = null;
    public static RequestParameterParser getInstance() {

        if (requestParameterParser == null) requestParameterParser = new RequestParameterParser();
        return requestParameterParser;
    }

    public Hashtable parseRequestParameters(HttpServletRequest request, String str) {

        ////Debug.println("\n\n\n ====  parseRequestParameters [START] ==================================================================================== ");

        Hashtable requestParameters = new Hashtable();
         String parameterName, parameterValue;
        Enumeration eParameterNames = request.getParameterNames();

        while(eParameterNames.hasMoreElements()) {

            parameterName = (String) eParameterNames.nextElement();

            parameterValue = request.getParameter(parameterName);

            if (str == null) {

                requestParameters.put(parameterName, parameterValue);
                ////Debug.println("requestParameters.put(parameterName="+parameterName+" , parameterValue=)"+parameterValue);

            } else if (parameterName.indexOf(str) >= 0) {

                requestParameters.put(parameterName, parameterValue);
                ////Debug.println("requestParameters.put(parameterName="+parameterName+" , parameterValue=)"+parameterValue);
            }
        }

        ////Debug.println("\n\n\n ====  parseRequestParameters [END] ==================================================================================== ");

        return requestParameters;
    }
}