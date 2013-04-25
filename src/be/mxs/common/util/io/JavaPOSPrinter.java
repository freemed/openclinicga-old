package be.mxs.common.util.io;

import java.net.URL;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import jpos.JposConst;
import jpos.JposException;
import jpos.POSPrinter;
import jpos.POSPrinterConst;
import jpos.events.ErrorEvent;
import jpos.events.ErrorListener;
import jpos.events.OutputCompleteEvent;
import jpos.events.OutputCompleteListener;
import jpos.events.StatusUpdateEvent;
import jpos.events.StatusUpdateListener;
import jpos.util.JposPropertiesConst;

public class JavaPOSPrinter implements OutputCompleteListener, StatusUpdateListener, ErrorListener {
	public static String ESC = ((char) 0x1b) + "";
	public static String LF = ((char) 0x0a) + "";
	public static String SPACES = "                                                                      ";
	public static String CENTER = ESC + "|cA";
	public static String LARGE = ESC + "|4C";
	public static String DOUBLE = ESC + "|2C";
	public static String REGULAR = ESC + "|1C";
	public static String BOLD = ESC + "|bC";
	public static String ITALIC = ESC + "|iC";
	public static String NORMAL = ESC + "|N";
	public static String UNDERLINE = ESC + "|uC";
	public static String NOTBOLD = ESC + "|!bC";
	public static String NOTITALIC = ESC + "|!iC";
	public static String NOTUNDERLINE = ESC + "|!uC";
	public static String RIGHT = ESC + "|rA";
	public static String LEFT = ESC + "|lA";
	
	public void outputCompleteOccurred(OutputCompleteEvent event) {
	}

	public void statusUpdateOccurred(StatusUpdateEvent event) {
	}

	public void errorOccurred(ErrorEvent event) {
		try {
			Thread.sleep(1000);
		} catch (Exception e) {
		}
		event.setErrorResponse(JposConst.JPOS_ER_RETRY);
	}

	public String printReceipt(String project,String sLanguage, String content,String barcode){
		String error="";
		System.setProperty(JposPropertiesConst.JPOS_POPULATOR_FILE_URL_PROP_NAME, MedwanQuery.getInstance().getConfigString("jposFile","http://localhost/openclinic/_common/xml/")+"jpos.xml");
		POSPrinter printer = new POSPrinter();
		try {
			printer.addOutputCompleteListener(this);
			printer.addStatusUpdateListener(this);
			printer.addErrorListener(this);
			printer.open(MedwanQuery.getInstance().getConfigString("JavaPOSPrinter","Star TSP100 Cutter (TSP143)_1"));
			printer.claim(1);
			printer.setDeviceEnabled(true);
			printer.setAsyncMode(true);
			printer.setMapMode(POSPrinterConst.PTR_MM_METRIC); // unit = 1/100 mm - i.e. 1 cm = 10 mm = 10 * 100 units
			do {
				if (printer.getCoverOpen() == true) {
					error=ScreenHelper.getTranNoLink("web","javapos.printercoveropen",sLanguage);
					break;
				}
				if (printer.getRecEmpty() == true) {
					error=ScreenHelper.getTranNoLink("web","javapos.printerpaperout",sLanguage);
					break;
				}
				// being a transaction
				// transaction mode causes all output to be buffered
				// once transaction mode is terminated, the buffered data is
				// sent to the printer in one shot - increased reliability
				printer.transactionPrint(POSPrinterConst.PTR_S_RECEIPT, POSPrinterConst.PTR_TP_TRANSACTION);
				if (printer.getCapRecBitmap() == true) {
					try {
				        String imageSource=MedwanQuery.getInstance().getConfigString("baseDirectory","c:/projects/openclinic");
				        //Try to find the image in the project image directory
				        String sLogo=imageSource+"/projects/"+project+"/_img/JavaPOSImage1.gif";
				        printer.printBitmap(POSPrinterConst.PTR_S_RECEIPT, sLogo, POSPrinterConst.PTR_BM_ASIS, POSPrinterConst.PTR_BM_CENTER);
					} catch (JposException e) {
						e.printStackTrace();
						error=e.getMessage();
						if (e.getErrorCode() == JposConst.JPOS_E_NOEXIST) {
							error=e.getErrorCode()+": "+ScreenHelper.getTranNoLink("web","javapos.imagedoesnotexist",sLanguage);
							//break;
						}
					}
				}
				
				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, ESC + "|cA" + ESC + "|4C" + ESC + "|bC" + ScreenHelper.getTranNoLink("web","javaposcentername",sLanguage) + LF);
				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, ESC + "|cA" + ESC + "|bC" + ScreenHelper.getTranNoLink("web","javaposcentersubtitle",sLanguage) + LF);
				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, ESC + "|cA" + ESC + "|bC" + ScreenHelper.getTranNoLink("web","javaposcenterphone",sLanguage) + LF);
				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, content);

				if (ScreenHelper.checkString(barcode).length()>0 && printer.getCapRecBarCode() == true) {
					// print a Code 3 of 9 barcode with the data "123456789012" encoded
					// the 10 * 100, 60 * 100 parameters below specify the barcode's
					// height and width in the metric map mode (1cm tall, 6cm wide)
					printer.printBarCode(POSPrinterConst.PTR_S_RECEIPT, barcode, POSPrinterConst.PTR_BCS_Code39,
							10 * 100, 60 * 100, POSPrinterConst.PTR_BC_CENTER, POSPrinterConst.PTR_BC_TEXT_BELOW);
				}

				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, ESC + "|cA" + ESC + "|4C" + ESC + "|bC" + ScreenHelper.getTranNoLink("web","thankyou",sLanguage) + LF);
				// the ESC + "|100fP" control code causes the printer to execute
				// a paper cut after feeding to the cutter position
				printer.printNormal(POSPrinterConst.PTR_S_RECEIPT, ESC + "|100fP");
				// terminate the transaction causing all of the above buffered
				// data to be sent to the printer
				printer.transactionPrint(POSPrinterConst.PTR_S_RECEIPT, POSPrinterConst.PTR_TP_NORMAL);
			} while (false);
		} catch (JposException e) {
			// display any errors that come up
			e.printStackTrace();
			error=e.getMessage();
		} catch (Exception e) {
			e.printStackTrace();
			error=e.getMessage();
		} finally {
			// close the printer object
			if (printer.getState() != JposConst.JPOS_S_CLOSED) {
				try {
					while (printer.getState() != JposConst.JPOS_S_IDLE) {
						Thread.sleep(5);
					}

					printer.close();
				} catch (Exception e) {
					error=e.getMessage();
				}
			}
		}
		return error;

	}
}
