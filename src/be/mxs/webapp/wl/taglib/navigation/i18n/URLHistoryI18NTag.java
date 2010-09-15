package be.mxs.webapp.wl.taglib.navigation.i18n;

import be.dpms.medwan.common.model.IConstants;
import javax.servlet.jsp.tagext.TagSupport;
import javax.servlet.jsp.JspException;
import java.util.Locale;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import org.apache.struts.util.ResponseUtils;
import org.apache.struts.util.RequestUtils;
import org.apache.struts.util.MessageResources;
import org.apache.struts.action.Action;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-avr.-2003
 * Time: 15:22:17
 * To change this template use Options | File Templates.
 */
public class URLHistoryI18NTag extends TagSupport {

    // ------------------------------------------------------------- Properties

    /*
    * The first optional argument.
    */
   protected String arg0 = null;

   public String getArg0() {
   return (this.arg0);
   }

   public void setArg0(String arg0) {
   this.arg0 = arg0;
   }


   /**
    * The second optional argument.
    */
   protected String arg1 = null;

   public String getArg1() {
   return (this.arg1);
   }

   public void setArg1(String arg1) {
   this.arg1 = arg1;
   }


   /**
    * The third optional argument.
    */
   protected String arg2 = null;

   public String getArg2() {
   return (this.arg2);
   }

   public void setArg2(String arg2) {
   this.arg2 = arg2;
   }


   /**
    * The fourth optional argument.
    */
   protected String arg3 = null;

   public String getArg3() {
   return (this.arg3);
   }

   public void setArg3(String arg3) {
   this.arg3 = arg3;
   }


   /**
    * The fifth optional argument.
    */
   protected String arg4 = null;

   public String getArg4() {
   return (this.arg4);
   }

   public void setArg4(String arg4) {
   this.arg4 = arg4;
   }


   /**
    * The servlet context attribute key for our resources.
    */
   protected String bundle = Action.MESSAGES_KEY;

   public String getBundle() {
   return (this.bundle);
   }

   public void setBundle(String bundle) {
   this.bundle = bundle;
   }


   /**
    * The default Locale for our server.
    */
   protected static final Locale defaultLocale = Locale.getDefault();


   /**
    * The message key of the message to be retrieved.
    */
   protected String key = null;

   public String getKey() {
   return (this.key);
   }

   public void setKey(String key) {
   this.key = key;
   }


   /**
    * The session scope key under which our Locale is stored.
    */
   protected String localeKey = Action.LOCALE_KEY;

   public String getLocale() {
   return (this.localeKey);
   }

   public void setLocale(String localeKey) {
   this.localeKey = localeKey;
   }


   /**
    * The message resources for this package.
    */
   protected static MessageResources messages =
   MessageResources.getMessageResources
   ("org.apache.struts.taglib.bean.LocalStrings");

    private String uri;
    private String action;

    private String name;
    private String property;
    private String scope = "session";

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getProperty() {
        return property;
    }

    public void setProperty(String property) {
        this.property = property;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }


    // --------------------------------------------------------- Private Methods

    private String getUri() {
        return uri;
    }

    private String getAction() {
        return action;
    }

    private String getDisplayNameI18N() throws JspException {
        // Construct the optional arguments array we will be using
        Object args[] = new Object[5];
        args[0] = arg0;
        args[1] = arg1;
        args[2] = arg2;
        args[3] = arg3;
        args[4] = arg4;


        if (getKey() == null) {

            Object o = null;

            if (getScope().equals("session")) {

                o = pageContext.getAttribute(getName(), pageContext.SESSION_SCOPE);

            } else if (getScope().equals("request")) {

                o = pageContext.getAttribute(getName(), pageContext.REQUEST_SCOPE);

            } else if (getScope().equals("page")) {

                o = pageContext.getAttribute(getName(), pageContext.PAGE_SCOPE);

            }

            if (o != null) {

                try {

                    String _property = getProperty();
                    String innerPropertyName, innerGetterName;
                    Method _method;

                    while (_property.indexOf(".") > 0) {

                        innerPropertyName = _property.substring(0, _property.indexOf("."));
                        innerGetterName = "get" + innerPropertyName.substring(0,1).toUpperCase() + innerPropertyName.substring(1);

                        _method = o.getClass().getMethod(innerGetterName, null);

                        o = _method.invoke(o, null);

                        _property = _property.substring(_property.indexOf(".") +1);
                    }

                    String getterName = "get" + _property.substring(0,1).toUpperCase() + _property.substring(1);

                    Method method = o.getClass().getMethod(getterName, null);

                    if (method.getReturnType() == String.class) {
                        String messageKey = (String)method.invoke(o, null);

                        setKey(messageKey);
                    }

                } catch (NoSuchMethodException e) {
                    e.printStackTrace();
                } catch (SecurityException e) {
                    e.printStackTrace();
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }

        // Retrieve the message string we are looking for
        String message = RequestUtils.message(pageContext, this.bundle,
                                                  this.localeKey, this.key, args);
        if (message == null) {
            message = key;
        }

        return message;
    }

    private String getRemoveFromHistoryQueryString(){
        String s;

        if (getUri().indexOf("?") == -1) {
            s = getUri() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId() + "&ts=" + new java.util.Date().hashCode();
        } else {
            s = getUri() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId() + "&ts=" + new java.util.Date().hashCode();
        }

        return s;
    }

    private String getAddToHistoryQueryString() throws JspException {
        String s;

        if (getUri().indexOf("?") == -1) {
            s = getUri() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayNameI18N() + "&ts=" + new java.util.Date().hashCode();
        } else {
            s = getUri() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayNameI18N() + "&ts=" + new java.util.Date().hashCode();
        }

        return s;
    }

    // --------------------------------------------------------- Public Methods

    public void setUri(String uri){
        this.uri = uri;
    }

    public void setAction(String action){
        this.action = action;
    }

    /**
     * Process the start tag.
     *
     */

    public int doStartTag() throws JspException {

        String html = null;

        if (getAction().equals(IConstants.ADD)) {

            html = getAddToHistoryQueryString();

        }  else if (getAction().equals(IConstants.REMOVE)) {

            html = getRemoveFromHistoryQueryString();

        }

	// Print the retrieved message to our output writer
        ResponseUtils.write(pageContext, html);

	// Continue processing this page
	    return (SKIP_BODY);

    }

    /**
     * Release any acquired resources.
     */
    public void release() {

        super.release();
        arg0 = null;
        arg1 = null;
        arg2 = null;
        arg3 = null;
        arg4 = null;
        bundle = Action.MESSAGES_KEY;
        key = null;
        localeKey = Action.LOCALE_KEY;

    }
}