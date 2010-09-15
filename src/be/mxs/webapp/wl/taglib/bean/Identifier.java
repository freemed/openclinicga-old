package be.mxs.webapp.wl.taglib.bean;

import be.dpms.medwan.common.model.IConstants;
import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.webapp.wo.common.system.SessionContainerWO;

import javax.servlet.jsp.tagext.TagSupport;
import javax.servlet.jsp.JspException;
import java.io.IOException;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.util.Locale;

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
public class Identifier extends TagSupport {

    // ------------------------------------------------------------- Properties

    private String name;
    private String property;
    private String scope = "session";
    private String prefix ="" ;
    private String suffix ="" ;

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

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getSuffix() {
        return suffix;
    }

    public void setSuffix(String suffix) {
        this.suffix = suffix;
    }


    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

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

                IIdentifiable identifiableObject = null;

                if ( (getProperty() != null) && (!getProperty().equals(""))) {

                    String propertyAccessor = "get" + getProperty().substring(0,1).toUpperCase() + getProperty().substring(1);

                    Method identifiableObjectAccessor = o.getClass().getMethod(propertyAccessor, null);

                    identifiableObject = (IIdentifiable)identifiableObjectAccessor.invoke(o, null);

                } else {

                    identifiableObject = (IIdentifiable) o;
                }

                IdentifierFactory identifierFactory = IdentifierFactory.getInstance();
                String identifier = identifierFactory.getIdentifier(identifiableObject, getPrefix(), getSuffix());

                pageContext.getOut().print(identifier);

            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (SecurityException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
        // Continue processing this page
	return (SKIP_BODY);

    }


}
