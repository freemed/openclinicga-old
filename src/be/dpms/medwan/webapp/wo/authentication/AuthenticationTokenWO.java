package be.dpms.medwan.webapp.wo.authentication;

import be.dpms.medwan.common.model.IConstants;

import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 15-avr.-2003
 * Time: 10:59:16
 * To change this template use Options | File Templates.
 */
public class AuthenticationTokenWO {

    private Hashtable hashtable = null;

    public AuthenticationTokenWO() {
        hashtable = new Hashtable();
    }

    public void setInitialHTTPRequest(String initialHTTPRequest) {
        hashtable.put(IConstants.AUTHENTICATION_TOKEN_INITIAL_HTTP_REQUEST, initialHTTPRequest);
    }

    public String getInitialHTTPRequest() {
        return (String)hashtable.get(IConstants.AUTHENTICATION_TOKEN_INITIAL_HTTP_REQUEST);
    }
}
