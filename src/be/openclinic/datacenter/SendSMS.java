package be.openclinic.datacenter;
import java.io.File;
import java.util.Vector;

import org.smslib.*;
import org.smslib.AGateway.*;
import org.smslib.modem.*;

public class SendSMS {

	public void send(String portname,String port,int baud,String brand,String model,String pin,String destination,String message) throws Exception
	{
		OutboundNotification outboundNotification = new OutboundNotification();
		SerialModemGateway gateway = new SerialModemGateway(portname, port, baud, brand,model);
		gateway.setInbound(true);
		gateway.setOutbound(true);
		gateway.setProtocol(Protocols.PDU);
		gateway.setSimPin(pin);
		Service.getInstance().setOutboundMessageNotification(outboundNotification);
		Service.getInstance().addGateway(gateway);
		Service.getInstance().startService();
		OutboundMessage msg = new OutboundMessage(destination, message);
		Service.getInstance().sendMessage(msg);
		gateway.stopGateway();
		Service.getInstance().stopService();
		Service.getInstance().removeGateway(gateway);
	}

	public class OutboundNotification implements IOutboundMessageNotification
	{
		public void process(AGateway gateway, OutboundMessage msg)
		{
		}
	}
}
