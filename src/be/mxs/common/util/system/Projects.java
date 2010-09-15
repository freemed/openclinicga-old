package be.mxs.common.util.system;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.XMLWriter;
import java.util.Hashtable;
import java.util.Enumeration;
import java.io.FileWriter;

public class Projects{
        public Hashtable hProjects;

        public Projects(){
            hProjects = new Hashtable();
        }

        public Projects(Hashtable hProjects){
            this.hProjects = hProjects;
        }

        public org.dom4j.Document toXML(){
            org.dom4j.Document document = DocumentHelper.createDocument();
            Element projects = document.addElement("projects");
            Enumeration e = hProjects.keys();
            String key;
            while(e.hasMoreElements())
            {
                key = (String)e.nextElement();
                ((Project)hProjects.get(key)).toXML(projects);
            }
            return document;
        }

        public static void writeXML(String sFilename, Hashtable hProjects){
            try{
            if(!hProjects.isEmpty()){
                XMLWriter writer = new XMLWriter(new FileWriter(sFilename));
                Projects projects = new Projects(hProjects);
                writer.write(projects.toXML());
                writer.close();
            }
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
