package be.openclinic.datacenter;
import java.io.File;
import java.util.Vector;

import org.smslib.*;
import org.smslib.AGateway.*;
import org.smslib.modem.*;

public class SendSMS {

	public void send(String portname,String port,int baud,String brand,String model,String pin) throws Exception
	{
		OutboundNotification outboundNotification = new OutboundNotification();
		System.out.println("Example: Send message from a serial gsm modem.");
		System.out.println(Library.getLibraryDescription());
		System.out.println("Version: " + Library.getLibraryVersion());
		SerialModemGateway gateway = new SerialModemGateway(portname, port, baud, brand,model);
		gateway.setInbound(true);
		gateway.setOutbound(true);
		gateway.setProtocol(Protocols.PDU);
		gateway.setSimPin(pin);
		Service.getInstance().setOutboundMessageNotification(outboundNotification);
		Service.getInstance().addGateway(gateway);
		Service.getInstance().startService();
		System.out.println();
		System.out.println("Modem Information:");
		System.out.println("  Manufacturer: " + gateway.getManufacturer());
		System.out.println("  Model: " + gateway.getModel());
		System.out.println("  Serial No: " + gateway.getSerialNo());
		System.out.println("  SIM IMSI: " + gateway.getImsi());
		System.out.println("  Signal Level: " + gateway.getSignalLevel() + " dBm");
		System.out.println("  Battery Level: " + gateway.getBatteryLevel() + "%");
		System.out.println();
		// Send a message synchronously.
		//OutboundMessage msg = new OutboundMessage("+32495120442", "Hello from SMSLib!");
		OutboundMessage msg = new OutboundMessage("+32475621569", "Hello from SMSLib!");
		Service.getInstance().sendMessage(msg);
		System.out.println(msg);
		//msg = new OutboundMessage("+309999999999", "Wrong number!");
		//srv.queueMessage(msg, gateway.getGatewayId());
		//msg = new OutboundMessage("+308888888888", "Wrong number!");
		//srv.queueMessage(msg, gateway.getGatewayId());
		System.out.println("Message sent...");
		gateway.stopGateway();
		Service.getInstance().stopService();
		Service.getInstance().removeGateway(gateway);
	}

	public class OutboundNotification implements IOutboundMessageNotification
	{
		public void process(AGateway gateway, OutboundMessage msg)
		{
			System.out.println("Outbound handler called from Gateway: " + gateway.getGatewayId());
			System.out.println(msg);
		}
	}
}
