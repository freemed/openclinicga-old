package be.mxs.webapp.wl.taglib.bean.util;

import be.dpms.medwan.common.model.IConstants;
import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.util.BeanAccessor;
import be.mxs.webapp.wo.common.system.SessionContainerWO;

import javax.servlet.jsp.tagext.TagSupport;
import javax.servlet.jsp.JspException;
import java.io.IOException;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.util.Locale;
import java.util.Calendar;
import java.util.Date;

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
public class DateFormat extends TagSupport {

    // ------------------------------------------------------------- Properties

    private String name="";
    private String property="";
    private String scope = "session";
    private String timeField="";
    private String value = "";

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
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

    public String getTimeField() {
        return timeField;
    }

    public void setTimeField(String timeField) {
        this.timeField = timeField;
    }

    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

        ////Debug.println("------------------------------------------------------- DATE_FORMAT : getValue() = " + getValue());
        Object o = null;

        if (getValue().equalsIgnoreCase("now")) {

            o = new java.util.Date();

        } else if (getScope().equals("session")) {

            o = pageContext.getAttribute(getName(), pageContext.SESSION_SCOPE);

        } else if (getScope().equals("request")) {

            o = pageContext.getAttribute(getName(), pageContext.REQUEST_SCOPE);

        } else if (getScope().equals("page")) {

            o = pageContext.getAttribute(getName(), pageContext.PAGE_SCOPE);

        }

        ////Debug.println("------------------------------------------------------- DATE_FORMAT : o = " + o);

        if (o != null) {

            ////Debug.println("o = " + o);
            try {

                java.util.Date date = null;

                if ( (getProperty() != null) && (!getProperty().equals(""))) {

                    date = (java.util.Date) BeanAccessor.getInstance().getPropertyValue(o, getProperty());

                } else {

                    date = (java.util.Date) o;
                }

                int _timeField = -1;

                if (getTimeField().equalsIgnoreCase("day")) _timeField = Calendar.DAY_OF_MONTH;
                else if (getTimeField().equalsIgnoreCase("month")) _timeField = Calendar.MONTH;
                else if (getTimeField().equalsIgnoreCase("year")) _timeField = Calendar.YEAR;

                if (date == null) {

                    pageContext.getOut().print("");

                } else if (_timeField != -1) {

                    Calendar c = Calendar.getInstance();
                    c.setTime(date);

                    String strTimeField = new String(new Integer(c.get(_timeField)).toString());

                    pageContext.getOut().print(strTimeField);

                } else if (getTimeField().equalsIgnoreCase("dd-mm-yyyy")) {

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
                    pageContext.getOut().print("Error : TimeField <" + getTimeField() + "> is unknown!");
                }

            } catch (SecurityException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            } catch (BeanAccessor.BeanAccessorException e) {
                e.printStackTrace();
            }
        }
        // Continue processing this page
	return (SKIP_BODY);

    }


}
