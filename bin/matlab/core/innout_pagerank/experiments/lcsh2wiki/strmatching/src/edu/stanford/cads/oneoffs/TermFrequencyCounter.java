package edu.stanford.cads.oneoffs;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import cs224n.util.Counter;
import cs224n.util.PriorityQueue;

public class TermFrequencyCounter {
	static Counter<String> tf = new Counter<String>();
	static void train(String filename) {
   		try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(filename)), 524288);
			String line;
			
			while ((line = in.readLine()) != null) {
				String[] ws = line.split(" ");
				for (String w:ws) {
					w=w.replace(",", "");
					w=w.replace(",", "");
					w=w.replace("(", "");
					w=w.replace(")", "");
					
					tf.incrementCount(w.toLowerCase(), 1);
				}
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
		
	}
	public static void main(String[] args) {
		if (args.length != 2 && args.length != 3) {
			System.err.println("usage: wikipedia_category_file lcsh_file [standard|droppunct|grams]");
		}		
		String wc_path = args[0];
		String lcsh_path = args[1];
		train(wc_path);
		train(lcsh_path);
		PriorityQueue<String> q = tf.asPriorityQueue();
		int limit = 100;
		limit = Math.min(limit, q.size());
		
		for (int i=0;i < limit ; i++) {
			String w = q.peek();
			int count = (int)tf.getCount(w);
			System.out.println(i+":\t"+q.next()+"\t"+count);
		}
	}
}
