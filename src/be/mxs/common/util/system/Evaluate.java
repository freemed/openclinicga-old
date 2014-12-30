package be.mxs.common.util.system;

import java.util.Enumeration;
import java.util.Hashtable;

import net.objecthunter.exp4j.Expression;
import net.objecthunter.exp4j.ExpressionBuilder;

public class Evaluate {
	
	public static String evaluate(String expression, Hashtable parameters,int precision) throws Exception{
		System.out.println("expression="+expression);
		System.out.println("precision="+precision);
		return String.format("%."+precision+"f%n", evaluate(expression,parameters));
	}

	public static double evaluate(String expression, Hashtable parameters) throws Exception{
		if(parameters!=null){
			Enumeration enumeration = parameters.keys();
			while(enumeration.hasMoreElements()){
				String key = (String)enumeration.nextElement();
				expression=expression.replaceAll(key, (String)parameters.get(key));
			}
		}
		Expression e = new ExpressionBuilder(expression).build();
		if(e.validate(false).isValid()){
			return e.evaluate();
		}
		else {
			throw new Exception();
		}
	}

}
