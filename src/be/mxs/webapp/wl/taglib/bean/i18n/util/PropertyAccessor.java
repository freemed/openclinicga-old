package be.mxs.webapp.wl.taglib.bean.i18n.util;

import be.mxs.common.model.util.BeanAccessor;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

import javax.servlet.jsp.tagext.TagSupport;
import java.lang.reflect.Method;
import java.util.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import org.apache.struts.util.MessageResources;
import org.apache.struts.action.Action;
import net.admin.User;


public class PropertyAccessor extends TagSupport {

    // Properties
    private String name;
    private String property;
    private String scope = "session";
    private String toScope = "page";
    private String toBean = null;
    private String output = "true";
    private String outputString = null;
    private String translate = "true";
    private String compare = "";
    private Hashtable comparator = null;
    private String formatType = "string";
    private String format = null;
    private String defaultValue = null;
    private String seek="true";


    public String getSeek() {
        return seek;
    }

    public void setSeek(String seek) {
        this.seek = seek;
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

    protected String bundle = Action.MESSAGES_KEY;

    public String getBundle() {
        return (this.bundle);
    }

    public void setBundle(String bundle) {
        this.bundle = bundle;
    }

    /**
     * The message resources for this package.
     */
    protected static MessageResources messages = MessageResources.getMessageResources("org.apache.struts.taglib.bean.LocalStrings");

    //--- GET TRANSLATION --------------------------------------------------------------------------
    private String getTranslation(String key) {
        if ( getTranslate().equalsIgnoreCase("false") || key.equalsIgnoreCase("")){
            return key;
        }

        String message = null;

        if (key.trim().length()>0){
            if (getFormatType().equalsIgnoreCase("date")) {
                try {
                    Date date = null;
                    try {
                        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
                        date = simpleDateFormat.parse(key);
                    }
                    catch (ParseException e) {
                        try {
                            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy");
                            date = simpleDateFormat.parse(key);
                        }
                        catch (ParseException e2) {
                            e2.printStackTrace();
                        }
                    }

                    int _timeField = -1;

                         if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("day")) )  _timeField = Calendar.DAY_OF_MONTH;
                    else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("month")) ) _timeField = Calendar.MONTH;
                    else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("year")) ) _timeField = Calendar.YEAR;

                    if (date!=null){
                        if (_timeField != -1) {
                            Calendar c = Calendar.getInstance();
                            c.setTime(date);
                            String strTimeField = new String(new Integer(c.get(_timeField)).toString());
                            message = strTimeField;
                        }
                        else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("dd-mm-yyyy")) ) {
                            Calendar c = Calendar.getInstance();
                            c.setTime(date);

                            String strTime = new String();
                            int day = c.get(Calendar.DAY_OF_MONTH);

                            if (day < 10) strTime = "0" + day + "/";
                            else strTime = "" + day + "/";

                            int month = c.get(Calendar.MONTH) + 1;
                            if (month < 10) strTime = strTime + "0" + month + "/";
                            else strTime = strTime + month + "/";

                            strTime = strTime + new String(new Integer(c.get(Calendar.YEAR)).toString());

                            message = strTime;
                        }
                    }
                }
                catch (Exception e){
                    if(Debug.enabled) Debug.println(e.getMessage());
                }
            }
            else {
                String sWebLanguage = pageContext.getSession().getAttribute("activeUser")!=null?((User)pageContext.getSession().getAttribute("activeUser")).person.language:null;
                if ((sWebLanguage==null)||(sWebLanguage.trim().length()==0)){
                    sWebLanguage = "N";
                }

                message = MedwanQuery.getInstance().getLabel("Web.Occup",key,sWebLanguage,seek.equalsIgnoreCase("true"));
            }
        }

        if (message == null) {
            message = key;
        }

        return message;
    }

    //--- GETTERS & SETTERS ------------------------------------------------------------------------
    public String getOutputString() {
        return outputString;
    }

    public void setOutputString(String outputString) {
        this.outputString = outputString;
    }

    public String getTranslate() {
        return translate;
    }

    public void setTranslate(String translate) {
        this.translate = translate;
    }

    public String getOutput() {
        return output;
    }

    public void setOutput(String output) {
        this.output = output;
    }

    public String getToScope() {
        return toScope;
    }

    public void setToScope(String toScope) {
        this.toScope = toScope;
    }

    public String getToBean() {
        return toBean;
    }

    public void setToBean(String toBean) {
        this.toBean = toBean;
    }

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

    public String getCompare() {
        return compare;
    }

    public void setCompare(String compare) {
        this.compare = compare;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getFormatType() {
        return formatType;
    }

    public void setFormatType(String formatType) {
        this.formatType = formatType;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    //--- GET COMPARATOR ---------------------------------------------------------------------------
    private Hashtable getComparator() {
        if (comparator != null) return comparator;

        comparator = new Hashtable();
        String _compare = new String (getCompare());

        String comparatorField = null;
        if (_compare.indexOf("=") > 0) comparatorField = _compare.substring(0, _compare.indexOf("="));
        String comparatorValue;

        while (comparatorField != null) {
            comparatorValue = null;

            if (_compare.indexOf(";") > 0) {
                comparatorValue = _compare.substring(_compare.indexOf("=") + 1, _compare.indexOf(";"));
                _compare = _compare.substring( _compare.indexOf(";") + 1 );
            }
            else {
                comparatorValue = _compare.substring(_compare.indexOf("=") + 1, _compare.length());
                _compare = _compare.substring( _compare.indexOf("=") + 1 );
            }

            comparator.put(comparatorField, comparatorValue);

            if (_compare.indexOf("=") > 0) comparatorField = _compare.substring(0, _compare.indexOf("="));
            else comparatorField = null;
        }

        return comparator;
    }

    //--- IS COMPARABLE ----------------------------------------------------------------------------
    private boolean isComparable(Object o) {
        if (getComparator().size() == 0) return true;

        try {
            Enumeration fieldNames = getComparator().keys();
            String fieldName, fieldValue,getterName, objectFieldValue;
            Method method;

            while (fieldNames.hasMoreElements()) {
                fieldName = (String) fieldNames.nextElement();
                fieldValue = (String) getComparator().get(fieldName);
                getterName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);

                method = o.getClass().getMethod(getterName, null);
                objectFieldValue = (String) method.invoke(o, null);

                if (!objectFieldValue.equals(fieldValue)) return false;
            }
        }
        catch (Exception e) {
            return false;
        }

        return true;
    }

    //--- DO START TAG -----------------------------------------------------------------------------
    public int doStartTag() {
        comparator = null;
        Object o = null;

        String beanProperty = null;
        String beanName = new String ( getName() );
        if (beanName.indexOf(".") > 0) {
            beanProperty = beanName.substring(beanName.indexOf(".") +1, beanName.length());
            beanName = beanName.substring(0, beanName.indexOf("."));
        }

        if (getScope().equals("session")) {
            o = pageContext.getAttribute(beanName, pageContext.SESSION_SCOPE);
        }
        else if (getScope().equals("request")) {
            o = pageContext.getAttribute(beanName, pageContext.REQUEST_SCOPE);
        }
        else if (getScope().equals("page")) {
            o = pageContext.getAttribute(beanName, pageContext.PAGE_SCOPE);
        }

        if (o != null) {
            Object objectValue = null;
            String getterName = "get" + getProperty().substring(0,1).toUpperCase() + getProperty().substring(1);

            if (beanProperty != null)
                try {
                    o = BeanAccessor.getInstance().getPropertyValue(o, beanProperty);
                }
                catch (BeanAccessor.BeanAccessorException e) {
                    objectValue = null;
                }

            if (o instanceof Collection) {
                Iterator iterator = ((Collection)o).iterator();
                boolean found = false;
                Object _o;
                Method _method;
                java.util.Date date;
                Calendar c;
                String strTime;
                int day, month;

                while (iterator.hasNext() && (!found)) {
                    _o = iterator.next();

                    if (!isComparable(_o)) continue;
                    else found = true;

                    try {
                        _method = _o.getClass().getMethod(getterName, null);

                        if (_method.getReturnType().isAssignableFrom(java.lang.String.class)) {
                            objectValue = _method.invoke(_o, null);

                            if (objectValue == null) {
                                if (getToBean() != null) storeResult("");
                                if (getOutput().equalsIgnoreCase("true")) pageContext.getOut().print("");
                            }
                            else {
                                if (getToBean() != null) storeResult(getTranslation((String)objectValue));
                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else pageContext.getOut().print(getTranslation((String)objectValue));
                                }
                            }
                        }
                        else if (_method.getReturnType().isAssignableFrom(java.util.Date.class)) {
                            date = (java.util.Date) _method.invoke(_o, null);;

                            if (objectValue == null) {
                                if (getToBean() != null) storeResult("");
                                if (getOutput().equalsIgnoreCase("true")) pageContext.getOut().print("");
                            }
                            else {
                                int _timeField = -1;

                                     if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("day")) )  _timeField = Calendar.DAY_OF_MONTH;
                                else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("month")) ) _timeField = Calendar.MONTH;
                                else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("year")) ) _timeField = Calendar.YEAR;

                                if (_timeField != -1) {
                                    c = Calendar.getInstance();
                                    c.setTime(date);

                                    String strTimeField = new String(new Integer(c.get(_timeField)).toString());

                                    if (getToBean() != null) storeResult(strTimeField);

                                    if (getOutput().equalsIgnoreCase("true")) {
                                        if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                        else pageContext.getOut().print(strTimeField);
                                    }
                                }
                                else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("dd-mm-yyyy")) ) {
                                    c = Calendar.getInstance();
                                    c.setTime(date);

                                    strTime = new String();

                                    day = c.get(Calendar.DAY_OF_MONTH);
                                    if (day < 10) strTime = "0" + day + "/";
                                    else strTime = "" + day + "/";

                                    month = c.get(Calendar.MONTH) + 1;
                                    if (month < 10) strTime = strTime + "0" + month + "/";
                                    else strTime = strTime + month + "/";

                                    strTime = strTime + new String(new Integer(c.get(Calendar.YEAR)).toString());

                                    if (getToBean() != null) storeResult(strTime);

                                    if (getOutput().equalsIgnoreCase("true")) {
                                        if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                        else pageContext.getOut().print(strTime);
                                    }
                                }
                                else {
                                    if (getToBean() != null) storeResult(date.toString());
                                    if (getOutput().equalsIgnoreCase("true")) {
                                        if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                        else pageContext.getOut().print(date.toString());
                                    }
                                }
                            }
                        }
                        else if (_method.getReturnType().isAssignableFrom(java.lang.Integer.class)) {
                            objectValue = _method.invoke(_o, null);

                            if (objectValue == null) {
                                if (getToBean() != null) storeResult("");
                                if (getOutput().equalsIgnoreCase("true")) pageContext.getOut().print("");
                            }
                            else {
                                if (getToBean() != null) storeResult((objectValue).toString());

                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else pageContext.getOut().print((objectValue).toString());
                                }
                            }
                        }
                        else {
                            objectValue = (_method.invoke(o, null)).toString();
                            if (objectValue == null) {
                                if (getToBean() != null) storeResult("");
                                if (getOutput().equalsIgnoreCase("true")) pageContext.getOut().print("");
                            }
                            else {
                                if (getToBean() != null) storeResult((String)objectValue);

                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else  pageContext.getOut().print((String)objectValue);
                                }
                            }
                        }
                    }
                    catch (Exception e) {
                        objectValue = null;
                    }
                }
            }
            else {
                if (isComparable(o)) {
                    try {
                        Method _method = o.getClass().getMethod(getterName, null);

                        if (_method.getReturnType().isAssignableFrom(java.lang.String.class)) {
                            objectValue = _method.invoke(o, null);
                            if (getToBean() != null) storeResult(getTranslation((String)objectValue));

                            if (getOutput().equalsIgnoreCase("true")) {
                                if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                else  pageContext.getOut().print(getTranslation((String)objectValue));
                            }
                        }
                        else if (_method.getReturnType().isAssignableFrom(java.util.Date.class)) {
                            java.util.Date date = (java.util.Date) _method.invoke(o, null);
                            int _timeField = -1;

                                 if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("day")) )  _timeField = Calendar.DAY_OF_MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("month")) ) _timeField = Calendar.MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("year")) ) _timeField = Calendar.YEAR;

                            if (_timeField != -1) {
                                Calendar c = Calendar.getInstance();
                                c.setTime(date);

                                String strTimeField = new String(new Integer(c.get(_timeField)).toString());

                                if (getToBean() != null) storeResult(strTimeField);
                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else  pageContext.getOut().print(strTimeField);
                                }
                            }
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("dd-mm-yyyy")) ) {
                                Calendar c = Calendar.getInstance();
                                c.setTime(date);

                                String strTime = new String();

                                int day = c.get(Calendar.DAY_OF_MONTH);
                                if (day < 10) strTime = "0" + day + "/";
                                else strTime = "" + day + "/";

                                int month = c.get(Calendar.MONTH) + 1;
                                if (month < 10) strTime = strTime + "0" + month + "/";
                                else strTime = strTime + month + "/";

                                strTime = strTime + new String(new Integer(c.get(Calendar.YEAR)).toString());
                                if (getToBean() != null) storeResult(strTime);

                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else  pageContext.getOut().print(strTime);
                                }
                            }
                            else {
                                if (getToBean() != null) storeResult(date.toString());

                                if (getOutput().equalsIgnoreCase("true")) {
                                    if (getOutputString() != null) pageContext.getOut().print(getTranslation(getOutputString()));
                                    else  pageContext.getOut().print(date.toString());
                                }
                            }
                        }
                        else {
                            objectValue = (_method.invoke(o, null)).toString();
                        }
                    }
                    catch (Exception e) {
                        objectValue = null;
                    }
                }
            }
        }

        // Continue processing this page
	    return SKIP_BODY;
    }

    //--- STORE RESULT -----------------------------------------------------------------------------
    private void storeResult(String stringValue) {
        if (getToScope().equals("session")) {
            pageContext.setAttribute(getToBean(), stringValue, pageContext.SESSION_SCOPE);
        }

        if (getToScope().equals("page")) {
            pageContext.setAttribute(getToBean(), stringValue, pageContext.PAGE_SCOPE);
        }

        if (getToScope().equals("request")) {
            pageContext.setAttribute(getToBean(), stringValue, pageContext.REQUEST_SCOPE);
        }

        if (getToScope().equals("application")) {
            pageContext.setAttribute(getToBean(), stringValue, pageContext.APPLICATION_SCOPE);
        }
    }

}