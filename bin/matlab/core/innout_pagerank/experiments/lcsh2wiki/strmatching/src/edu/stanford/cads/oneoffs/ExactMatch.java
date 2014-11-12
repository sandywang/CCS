package edu.stanford.cads.oneoffs;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;

import org.apache.lucene.store.Directory;

public class ExactMatch {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length < 2) {
			System.err.println("Usage: ExactMatch path1 path2");
			return;
		}
		// case order
		// false false
		
		if (args.length == 3) {
			verbose=false;
			doExactMatch(args[0], args[1], false, false);
			doExactMatch(args[0], args[1], false, true);
			doExactMatch(args[0], args[1], true, false);
			doExactMatch(args[0], args[1], true, true);			
		} else {
			doExactMatch(args[0], args[1], false, false);			
		}
		
	}
	static boolean verbose=true;
	public static void doExactMatch(String wc, String lcsh, boolean isCaseSen, boolean isOrderSen) {
		isCaseSensitive=isCaseSen;
		isOrderSensitive=isOrderSen;	
		HashMap<String,Integer> target = new HashMap<String, Integer>(300000);
		HashMap<String,String> orgDict = new HashMap<String, String>(300000);
		long start,end;
		start = System.currentTimeMillis();
		int numDup=0;
		try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(lcsh)), 524288);
			String line;
			int i=0;
			while ((line = in.readLine()) != null) {
				String org = line;
				line = filter(line);
				orgDict.put(line,org);

				if (target.containsKey(line)) {
					numDup++;
					//System.err.print("duplicate items in target: ");
					//System.err.println(tar2.get(line));
					//System.err.println(line+" ---- "+ line2);

					//return;
				}
				target.put(line, i++);
				
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}       
		int count = 0;
		int i=0;
		HashSet<String> res = new HashSet<String>();
		try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(wc)), 524288);
			String line;
			
			while ((line = in.readLine()) != null) {
				int idx = -1;
				line = filter(line);
				Integer myInt = target.get(line);
				if (myInt != null) {
					count++;
					res.add(line);
					if (verbose) {
						System.out.println(i+"\t"+orgDict.get(line)+"\t"+myInt.intValue());
					}
				}
				i++;
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}       
		
		end = System.currentTimeMillis();
		System.err.println("CaseSensitive: "+isCaseSen+"\tisOrderSensitive :"+isOrderSen);
		System.err.println("|L1| = "+i+", |L2| = "+target.size());
		System.err.println("Exact Match = "+count);
		System.err.println("Unique Exact Matches = "+res.size());
		System.err.println(" ... done! (" + ((float)(end-start)/1000.0f) + " secs.)");		
	}
	static boolean isCaseSensitive = true;
	static boolean isOrderSensitive = false;
	static String filter(String s) {
		String result = s;
		if (!isCaseSensitive) {
			result = result.toLowerCase();
		}
		if (!isOrderSensitive) {
			String[] tokens = result.split(" ");
			ArrayList<String> myList = new ArrayList<String>();
			for (String t:tokens) {
				myList.add(t);
			}
			Collections.sort(myList);
			String out="";
			for (String t:myList) {
				out+=t+" ";
			}
			result = out.trim();
		}
		return result;
	}
}
