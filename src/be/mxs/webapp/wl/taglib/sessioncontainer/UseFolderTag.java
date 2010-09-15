package be.mxs.webapp.wl.taglib.sessioncontainer;

import be.mxs.webapp.wo.common.system.SessionContainerWO;

import javax.servlet.jsp.tagext.TagSupport;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-avr.-2003
 * Time: 15:22:17
 * To change this template use Options | File Templates.
 */
public class UseFolderTag extends TagSupport {

    // ------------------------------------------------------------- Properties

    private String id;
    private String name;

    // --------------------------------------------------------- Private Methods

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public int doStartTag() {

        SessionContainerWO sessionContainerWO = null;
        sessionContainerWO = (SessionContainerWO)pageContext.getAttribute(SessionContainerWO.SESSION_KEY_CONTAINER_WO, pageContext.SESSION_SCOPE);

        Object folder = sessionContainerWO.getFolder(getName());
        pageContext.setAttribute(id, folder, pageContext.PAGE_SCOPE);

        // Continue processing this page
    	return (SKIP_BODY);

    }
}