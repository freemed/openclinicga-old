package be.mxs.webapp.wl.taglib.bean.i18n;

import be.mxs.common.util.db.MedwanQuery;

import javax.servlet.jsp.tagext.TagSupport;
import java.lang.reflect.Method;
import java.util.Locale;

import org.apache.struts.util.MessageResources;
import org.apache.struts.action.Action;
import net.admin.User;

/**
 * User: Michaël
 * Date: 09-avr.-2003
 */
public class Translator extends TagSupport {

    // Properties
    private String name;
    private String property;
    private String scope = "session";
    private String seek = "true";
    private String language = "";

    protected String bundle = Action.MESSAGES_KEY;
    protected static final Locale defaultLocale = Locale.getDefault();
    protected String key = null;
    protected String localeKey = Action.LOCALE_KEY;
    protected static MessageResources messages = MessageResources.getMessageResources("org.apache.struts.taglib.bean.LocalStrings");


    //--- GETTERS & SETTERS -----------------------------------------------------------------------
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

    public String getSeek() {
        return seek;
    }

    public void setSeek(String seek) {
        this.seek = seek;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getBundle() {
        return this.bundle;
    }

    public void setBundle(String bundle) {
        this.bundle = bundle;
    }

    public String getKey() {
        return this.key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getLocale() {
        return this.localeKey;
    }

    public void setLocale(String localeKey) {
        this.localeKey = localeKey;
    }

    //------------------------------------ Private Methods ----------------------------------------

    private String getTranslation() {
        String sWebLanguage = pageContext.getSession().getAttribute("activeUser")!=null?((User)pageContext.getSession().getAttribute("activeUser")).person.language:null;
        if (sWebLanguage==null || sWebLanguage.trim().length()==0){
            sWebLanguage = "N";
        }
        String message = MedwanQuery.getInstance().getLabel("Web.Occup",key,sWebLanguage,seek.equalsIgnoreCase("true"));


        if (message == null) {
            message = key;
        }

        if (message == null) {
            message = "";
        }

        return message;
    }

    //------------------------------------- Public Methods ----------------------------------------

    public int doStartTag() {
        Object obj = null;

        if (getScope().equals("session")) {
            obj = pageContext.getAttribute(getName(), pageContext.SESSION_SCOPE);
        }
        else if (getScope().equals("request")) {
            obj = pageContext.getAttribute(getName(), pageContext.REQUEST_SCOPE);
        }
        else if (getScope().equals("page")) {
            obj = pageContext.getAttribute(getName(), pageContext.PAGE_SCOPE);
        }

        if (obj != null) {
            try {
                String _property = getProperty();

                if (_property != null && !_property.equals("")) {
                    String innerPropertyName, innerGetterName;
                    Method _method;

                    while (_property.indexOf(".") > 0) {
                        innerPropertyName = _property.substring(0,_property.indexOf("."));
                        innerGetterName = "get" + innerPropertyName.substring(0,1).toUpperCase() + innerPropertyName.substring(1);

                        _method = obj.getClass().getMethod(innerGetterName,null);
                        obj = _method.invoke(obj,null);
                        _property = _property.substring(_property.indexOf(".")+1);
                    }

                    String getterName = "get" + _property.substring(0,1).toUpperCase() + _property.substring(1);

                    // get method to invoke
                    Method method;
                    if(language.length()>0){
                        Class[] paramTypes = new Class[1];
                        paramTypes[0] = new String().getClass();
                        method = obj.getClass().getMethod(getterName,paramTypes);
                    }
                    else{
                        method = obj.getClass().getMethod(getterName,null);
                    }

                    // invoke method with or without params
                    if (method.getReturnType() == String.class){
                        String messageKey;
                        if(language.length()>0){
                            Object[] args = new Object[1];
                            args[0] = language;
                            messageKey = (String)method.invoke(obj,args);
                        }
                        else{
                            messageKey = (String)method.invoke(obj,null);
                        }
                        setKey(messageKey);
                        pageContext.getOut().print(getTranslation());
                    }
                } else {
                    String messageKey = (String)obj;

                    setKey(messageKey);
                    pageContext.getOut().print(getTranslation());
                }
            }
            catch(Exception e) {
                e.printStackTrace();
            }
        }

        // Continue processing this page
	    return SKIP_BODY;
    }
}