package be.mxs.common.util.system;

import org.dom4j.Element;
import java.util.Vector;
import java.util.Iterator;

public class Project {

    public final static String PARAM_DELETE = "delete";
    public final static String PARAM_SRC = "src";
    public final static String PARAM_DEST= "dest";
    public final static String PARAM_POOLMAN= "poolman";

    private String projectName;
    private Vector vParams;

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public Vector getParams() {
        return vParams;
    }

    public void setParams(Vector vParams) {
        this.vParams = vParams;
    }

    public Project(){
        this.projectName = "";
        vParams = new Vector();
    }

    public void parse(Element eProject){
        this.projectName = ScreenHelper.checkString(eProject.attributeValue("name"));

        Iterator params = eProject.elementIterator("param");
        Element eParam;
        ProjectParam param;

        while(params.hasNext()){
            eParam = (Element)params.next();
            param = new ProjectParam();
            param.parse(eParam);
            vParams.add(param);
        }
    }

    public void toXML(Element parent){
        Element eProject = parent.addElement("project").addAttribute("name",this.getProjectName());
        Iterator iter;
        iter = vParams.iterator();
        while(iter.hasNext()){
            ((ProjectParam)iter.next()).toXML(eProject);
        }
    }

    public ProjectParam getParam(String type){
      Iterator iter = this.vParams.iterator();
      ProjectParam editParam;
      while(iter.hasNext()){
          editParam = (ProjectParam)iter.next();
          if(editParam.getType().equals(type))
              return editParam;
      }
      return null;
    }
}

