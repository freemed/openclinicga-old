package be.mxs.webapp.wl.taglib.bean;

import be.mxs.common.model.util.BeanAccessor;
import javax.servlet.jsp.tagext.TagSupport;
import java.lang.reflect.Method;
import java.util.*;

public class PropertyAccessor extends TagSupport {

    // ------------------------------------------------------------- Properties

    private String name;
    private String property;
    private String scope = "session";
    private String compare;
    private Hashtable comparator = null;

    private String format = null;
    private String defaultValue = null;

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

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    private Hashtable getComparator() {

        if (comparator != null) return comparator;

        comparator = new Hashtable();

        String _compare = new String (getCompare());

        ////Debug.println("getComparator() => getCompare() = " + getCompare());

        String comparatorField = null;
        int iIndex = _compare.indexOf("=");
        if (iIndex > 0) comparatorField = _compare.substring(0, _compare.indexOf("="));
        String comparatorValue;

        while (comparatorField != null) {

            comparatorValue = null;

            if (_compare.indexOf(";") > 0) {
                comparatorValue = _compare.substring(iIndex + 1, _compare.indexOf(";"));
                _compare = _compare.substring( _compare.indexOf(";") + 1 );
            }
            else {
                comparatorValue = _compare.substring(iIndex + 1, _compare.length());
                _compare = _compare.substring( iIndex + 1 );
            }

            comparator.put(comparatorField, comparatorValue);

            ////Debug.println("comparator.put(comparatorField="+comparatorField+", comparatorValue="+comparatorValue+");");
            ////Debug.println("_compare = "+_compare);
            iIndex = _compare.indexOf("=");
            if (iIndex > 0) comparatorField = _compare.substring(0, iIndex);
            else comparatorField = null;
        }

        return comparator;
    }

    private boolean isComparable(Object o) {

        ////Debug.println("-------------------------------- isComparable ?");

        try {
            Enumeration fieldNames = getComparator().keys();
            String fieldName, fieldValue, getterName, objectFieldValue;
            Method method;

            while (fieldNames.hasMoreElements()) {

                fieldName = (String) fieldNames.nextElement();
                fieldValue = (String) getComparator().get(fieldName);

                ////Debug.println("fieldName = " + fieldName);
                ////Debug.println("fieldValue = " + fieldValue);

                getterName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);

                ////Debug.println("getterName = " + getterName);

                method = o.getClass().getMethod(getterName, null);
                objectFieldValue = (String) method.invoke(o, null);

                ////Debug.println("objectFieldValue = " + objectFieldValue);

                if (!objectFieldValue.equals(fieldValue)) return false;
            }

        } catch (Exception e) {
            ////Debug.println(e.getMessage());
            return false;
        }

        ////Debug.println("-------------------------------- isComparable is TRUE !");
        return true;
    }


    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

        comparator = null;

        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");

        Object o = null;

        String beanProperty = null;
        String beanName = new String ( getName() );
        if (beanName.indexOf(".") > 0) {
            beanProperty = beanName.substring(beanName.indexOf(".") +1, beanName.length());
            beanName = beanName.substring(0, beanName.indexOf("."));
        }

        ////Debug.println("beanName = " + beanName);
        ////Debug.println("beanProperty = " + beanProperty);

        if (getScope().equals("session")) {

            o = pageContext.getAttribute(beanName, pageContext.SESSION_SCOPE);

        } else if (getScope().equals("request")) {

            o = pageContext.getAttribute(beanName, pageContext.REQUEST_SCOPE);

        } else if (getScope().equals("page")) {

            o = pageContext.getAttribute(beanName, pageContext.PAGE_SCOPE);

        }

        if (o != null) {

            ////Debug.println("(1) o = " + o);

            Object objectValue = null;
            String getterName = "get" + getProperty().substring(0,1).toUpperCase() + getProperty().substring(1);

            if (beanProperty != null)
                try {

                    o = BeanAccessor.getInstance().getPropertyValue(o, beanProperty);

                } catch (BeanAccessor.BeanAccessorException e) {

                    objectValue = null;
                }

            ////Debug.println("(2) o = " + o);

            if (o instanceof Collection) {

                Iterator iterator = ( (Collection) o).iterator();
                boolean found = false;
                Object _o;
                Method _method;
                java.util.Date date;
                int _timeField, day, month;
                Calendar c;
                String strTime;

                while (iterator.hasNext() && (!found)) {

                    _o = iterator.next();

                    if (!isComparable(_o)) continue;
                    else found = true;

                    try {

                        ////Debug.println("_o = " + _o);
                        ////Debug.println("getterName = " + getterName);

                        _method = _o.getClass().getMethod(getterName, null);
                        //objectValue = (String )_method.invoke(_o, null);
                        if (_method.getReturnType().isAssignableFrom(java.lang.String.class)) {

                            ////Debug.println("_method.getReturnType() = String");
                            objectValue = (String)_method.invoke(_o, null);
                            ////Debug.println("objectValue = " + objectValue);
                            pageContext.getOut().print((String)objectValue);

                        } else if (_method.getReturnType().isAssignableFrom(java.util.Date.class)) {

                            ////Debug.println("_method.getReturnType() = Date");

                            date = (java.util.Date) _method.invoke(_o, null);;

                            ////Debug.println(" Date = "+date);
                            _timeField = -1;

                            if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("day")) )  _timeField = Calendar.DAY_OF_MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("month")) ) _timeField = Calendar.MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("year")) ) _timeField = Calendar.YEAR;

                            if (_timeField != -1) {

                                c = Calendar.getInstance();
                                c.setTime(date);

                                String strTimeField = new String(new Integer(c.get(_timeField)).toString());

                                pageContext.getOut().print(strTimeField);

                            } else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("dd-mm-yyyy")) ) {

                                ////Debug.println("format = "+getFormat());

                                c = Calendar.getInstance();
                                c.setTime(date);

                                strTime = new String();

                                day = c.get(Calendar.DAY_OF_MONTH);
                                if (day < 10) strTime = "0" + day + "-";
                                else strTime = "" + day + "-";

                                month = c.get(Calendar.MONTH) + 1;
                                if (month < 10) strTime = strTime + "0" + month + "-";
                                else strTime = strTime + month + "-";

                                strTime = strTime + new String(new Integer(c.get(Calendar.YEAR)).toString());

                                ////Debug.println("strTime="+strTime);

                                pageContext.getOut().print(strTime);

                            } else {
                                pageContext.getOut().print(date.toString());
                            }


                        } else if (_method.getReturnType().isAssignableFrom(java.lang.Integer.class)) {

                            ////Debug.println("_method.getReturnType() = Integer");
                            objectValue = (java.lang.Integer)_method.invoke(_o, null);
                            pageContext.getOut().print(((Integer)objectValue).toString());
                            ////Debug.println("objectValue = " + objectValue);

                        } else {

                            ////Debug.println("_method.getReturnType() = Other");
                            objectValue = (_method.invoke(o, null)).toString();
                            pageContext.getOut().print((String)objectValue);
                            ////Debug.println("objectValue = " + objectValue);

                        }
                    } catch (Exception e) {
                        objectValue = null;
                        ////Debug.println(e.getMessage());
                    }
                }
            } else {

                if (isComparable(o)) {

                    try {

                        ////Debug.println("o = " + o);
                        ////Debug.println("getterName = " + getterName);

                        Method _method = o.getClass().getMethod(getterName, null);

                        if (_method.getReturnType().isAssignableFrom(java.lang.String.class)) {

                            ////Debug.println("_method.getReturnType() = String");
                            objectValue = (String)_method.invoke(o, null);
                            pageContext.getOut().print((String)objectValue);
                            ////Debug.println("objectValue = " + objectValue);

                        } else if (_method.getReturnType().isAssignableFrom(java.util.Date.class)) {

                            ////Debug.println("_method.getReturnType() = Date");
                            java.util.Date date = (java.util.Date) _method.invoke(o, null);
                            int _timeField = -1;

                            if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("day")) )  _timeField = Calendar.DAY_OF_MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("month")) ) _timeField = Calendar.MONTH;
                            else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("year")) ) _timeField = Calendar.YEAR;

                            if (_timeField != -1) {

                                Calendar c = Calendar.getInstance();
                                c.setTime(date);

                                String strTimeField = new String(new Integer(c.get(_timeField)).toString());

                                pageContext.getOut().print(strTimeField);

                            } else if ( (getFormat() != null ) && ( getFormat().equalsIgnoreCase("dd-mm-yyyy")) ) {

                                Calendar c = Calendar.getInstance();
                                c.setTime(date);

                                String strTime = new String();

                                int day = c.get(Calendar.DAY_OF_MONTH);
                                if (day < 10) strTime = "0" + day + "-";
                                else strTime = "" + day + "-";

                                int month = c.get(Calendar.MONTH) + 1;
                                if (month < 10) strTime = strTime + "0" + month + "-";
                                else strTime = strTime + month + "-";

                                strTime = strTime + new String(new Integer(c.get(Calendar.YEAR)).toString());

                                pageContext.getOut().print(strTime);

                            } else {
                                pageContext.getOut().print(date.toString());
                            }


                        } else {
                            ////Debug.println("_method.getReturnType() = Other");
                            objectValue = (_method.invoke(o, null)).toString();
                            ////Debug.println("objectValue = " + objectValue);
                        }
                    } catch (Exception e) {
                        objectValue = null;
                    }
                }
            }
/*
            try {
                ////Debug.println("TRY objectValue = " + objectValue);
                if (objectValue != null) {
                    pageContext.getOut().print(getTranslation((String)objectValue));
                } else {
                    if (getDefaultValue() != null ) pageContext.getOut().print(getTranslation(getDefaultValue()));
                        else pageContext.getOut().print("");
                }
            } catch (IOException e) {
                e.printStackTrace();
            } catch (JspException e) {
                e.printStackTrace();
            }
  */
        }

        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");
        ////Debug.println("-------------------------------------------------------------------------------------------");

        // Continue processing this page
	return (SKIP_BODY);

    }
}