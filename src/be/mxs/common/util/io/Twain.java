package be.mxs.common.util.io;

import SK.gnome.morena.Morena;
import SK.gnome.morena.MorenaImage;
import SK.gnome.morena.MorenaSource;
import SK.gnome.twain.TwainManager;
import be.mxs.common.util.system.Picture;
import com.sun.media.jai.codec.ImageCodec;

import javax.media.jai.JAI;
import javax.swing.*;
import javax.swing.border.LineBorder;
import javax.swing.filechooser.FileFilter;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.awt.image.ImageConsumer;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.net.URL;

public class Twain extends JApplet {
    private static class MainPanel extends JPanel{
        private JLabel status=new JLabel();
        private ImagePanel selected=null;
        private SaveImageAction saveImageAction;
        private UploadImageAction uploadImageAction;
        private AcquireImageAction acquireImageAction;
        private MouseListener mouseListener=new MouseListener();
        private boolean hasJAI=false;
        private boolean hasServer=false;
        private URL documentBase=null;
        private int personid;

        public void setPersonid(int personid) {
            this.personid = personid;
        }

        private class RemoveAllAction extends AbstractAction implements Runnable{
            RemoveAllAction(){
                super("remove all");
            }

            public synchronized void actionPerformed(ActionEvent event){
                new Thread(this).start();
            }

            public synchronized void run(){
                removeAll();
                select(null);
                repaint();
            }
        }

        private class AcquireImageAction extends AbstractAction implements Runnable{
            AcquireImageAction(){
                super("acquire image");
            }

            public synchronized void actionPerformed(ActionEvent event){
                new Thread(this).start();
            }

            public synchronized void run(){
                try{
                    status.setText("Working ...");
                    MorenaSource source= TwainManager.getDefaultSource();
                    if (source!=null){
                        source.setColorMode();
                        source.setResolution(100);
                        while (true){
                            MorenaImage morenaImage=new MorenaImage(source);
                            int imageStatus=morenaImage.getStatus();
                            if (imageStatus== ImageConsumer.STATICIMAGEDONE){
                                int imageWidth=morenaImage.getWidth();
                                int imageHeight=morenaImage.getHeight();
                                int imagePixelSize=morenaImage.getPixelSize();
                                ImagePanel image=new ImagePanel(Toolkit.getDefaultToolkit().createImage(morenaImage));
                                MainPanel.this.add(image);
                                select(image);
                                int size=(int)Math.round(Math.sqrt(getComponentCount()));
                                setLayout(new GridLayout(size, size));
                                status.setText("Done - actual image size is "+imageWidth+" x "+imageHeight+" x "+imagePixelSize+" ...");
                                validate();
                                uploadImageAction.run();
                            }
                            else if (imageStatus==ImageConsumer.IMAGEABORTED){
                                status.setText("Aborted, try again ...");
                            }
                            else if (imageStatus==ImageConsumer.IMAGEERROR){
                                status.setText("Failed, try again ...");
                            }
                            break;
                        }
                    }
                    else{
                        status.setText("Failed, try again ...");
                    }
                }
                catch (Exception e){
                    e.printStackTrace();
                }
                finally{
                    try{
                        Morena.close();
                    }
                    catch (Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }

        private class SaveImageAction extends AbstractAction implements Runnable{
            private class Filter extends FileFilter {
                String type;

                Filter(String type){
                    this.type=type.toUpperCase();
                }

                public boolean accept(File file){
                    String name=file.getName().toUpperCase();
                    return name.endsWith(type);
                }

                public String getDescription(){
                    return type+" Files";
                }
            }

            SaveImageAction(){
                super("save to file");
            }

            public void actionPerformed(ActionEvent event){
                new Thread(this).start();
            }

            public synchronized void run(){
                try{
                    status.setText("Working ...");
                    Image image=selected.getImage();
                    BufferedImage bufferedImage=new BufferedImage(image.getWidth(null), image.getHeight(null), BufferedImage.TYPE_INT_RGB);
                    bufferedImage.createGraphics().drawImage(image, 0, 0, null);
                    JFileChooser chooser=new JFileChooser();
                    String e[]=ImageCodec.getEncoderNames(bufferedImage, null);
                    for (int i=0; i<e.length; i++){
                        chooser.addChoosableFileFilter(new Filter(e[i]));
                    }
                    int result=chooser.showSaveDialog(MainPanel.this);
                    if (result==JFileChooser.APPROVE_OPTION){
                        String ext=chooser.getFileFilter().getDescription();
                        ext=ext.substring(0, ext.indexOf(' ')).toLowerCase();
                        File file=chooser.getSelectedFile();
                        String name=file.getName();
                        if (!name.endsWith(ext)){
                            file=new File(file.getParentFile(), name+"."+ext);
                        }
                        OutputStream tmp=new FileOutputStream(file);
                        ImageCodec.createImageEncoder(ext, tmp, null).encode(bufferedImage);
                        tmp.close();
                    }
                }
                catch (Throwable e){
                    e.printStackTrace();
                    status.setText("Failed, try again ...");
                }
            }

            public boolean isEnabled(){
                return hasJAI;
            }
        }

        private class UploadImageAction extends AbstractAction implements Runnable{
            UploadImageAction(){
                super("upload to server");
            }

            public void actionPerformed(ActionEvent event){
                new Thread(this).start();
            }

            public synchronized void run(){
                try{
                    status.setText("Working ...");
                    Image image=selected.getImage();
                    ByteArrayOutputStream tmp=new ByteArrayOutputStream();
                    BufferedImage bufferedImage=new BufferedImage(image.getWidth(null), image.getHeight(null), BufferedImage.TYPE_INT_RGB);
                    bufferedImage.createGraphics().drawImage(image, 0, 0, null);
                    ImageCodec.createImageEncoder("jpeg", tmp, null).encode(bufferedImage);
                    tmp.close();
                    int contentLength=tmp.size();
                    if (contentLength>1024*1024){
                        throw new Exception("Image is too big to upload");
                    }
                    Picture picture = new Picture(personid);
                    picture.setPicture(tmp.toByteArray());
                    if(picture.store()){
                        status.setText("Done - image is uploaded with size of"+tmp.size()+" bytes");
                        System.exit(0);
                    }
                    else {
                        status.setText("Failed to store picture ...");
                    }
                }
                catch (Throwable e){
                    e.printStackTrace();
                    status.setText("Failed, try again ...");
                }
            }

            public boolean isEnabled(){
                return hasJAI && hasServer && selected!=null;
            }
        }

        private class MouseListener extends MouseAdapter {
            public void mouseClicked(MouseEvent event){
                select((ImagePanel)event.getComponent());
            }
        }

        private class ImagePanel extends JPanel{
            private Image image;
            int imageWidth;
            int imageHeight;

            ImagePanel(Image image){
                this.image=image;
                imageWidth=image.getWidth(null);
                imageHeight=image.getHeight(null);
                addMouseListener(mouseListener);
            }

            public Image getImage(){
                return image;
            }

            public void paint(Graphics g){
                super.paint(g);
                int panelWidth=getWidth()-6;
                int panelHeight=getHeight()-6;
                double horizontalRatio=(double)panelWidth/imageWidth;
                double verticalRatio=(double)panelHeight/imageHeight;
                if (horizontalRatio>verticalRatio){
                    g.drawImage(image, (int)(panelWidth-imageWidth*verticalRatio)/2+3, 3, (int)(imageWidth*verticalRatio), (int)(imageHeight*verticalRatio), this);
                }
                else{
                    g.drawImage(image, 3, 3, (int)(imageWidth*horizontalRatio), (int)(imageHeight*horizontalRatio), this);
                }
            }
        }

        private class ToolBar extends JToolBar{
            ToolBar(){
                add(new RemoveAllAction());
                addSeparator();
                add(acquireImageAction=new AcquireImageAction());
                addSeparator();
                //add(saveImageAction=new SaveImageAction());
                //saveImageAction.setEnabled(false);
                //addSeparator();
                add(uploadImageAction=new UploadImageAction());
                uploadImageAction.setEnabled(false);
                setMargin(new Insets(4, 2, 2, 2));
            }
        }

        private class StatusBar extends JToolBar{
            StatusBar(){
                add(status);
                status.setText("Ready ...");
            }
        }

        void select(ImagePanel image){
            if (selected!=null){
                selected.setBorder(null);
            }
            selected=image;
            if (selected!=null){
                selected.setBorder(new LineBorder(Color.blue, 1));
                //saveImageAction.setEnabled(hasJAI);
                uploadImageAction.setEnabled(hasJAI);
            }
            else{
                saveImageAction.setEnabled(false);
                uploadImageAction.setEnabled(false);
            }
        }

        MainPanel(Container container, URL documentBase,int personid){
            try{
                if (JAI.class!=null){
                    hasJAI=true;
                }
            }
            catch (NoClassDefFoundError error){
                error.printStackTrace();
            }
            this.personid=personid;
            this.documentBase=documentBase;
            hasServer=documentBase!=null && documentBase.getProtocol().indexOf("http")!=-1;
            container.add(new ToolBar(), BorderLayout.NORTH);
            container.add(this, BorderLayout.CENTER);
            container.add(new StatusBar(), BorderLayout.SOUTH);
            setLayout(new GridLayout(1, 1));
            acquireImageAction.run();
        }

    }

    public void init(){
        new MainPanel(getContentPane(), getDocumentBase(),0);
    }

    public static void main(String args[]){ 
        JFrame frame=new JFrame("OpenClinic TWAIN GUI");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        MainPanel mainPanel=new MainPanel(frame.getContentPane(), null,args.length>0?Integer.parseInt(args[0]):0);
        frame.setBounds(100, 100, 600, 400);
        frame.setVisible(true);
    }

}
