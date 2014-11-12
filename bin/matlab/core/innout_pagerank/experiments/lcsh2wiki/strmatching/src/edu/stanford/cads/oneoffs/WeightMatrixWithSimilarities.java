package edu.stanford.cads.oneoffs;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

public class WeightMatrixWithSimilarities {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length != 3) {
			System.err.println("Usage: WeightMatrixWithSimilarities graph.smat cat1.nodes cat2.page");
			return;
		}
		SoftTFIDFAdapter dist = new SoftTFIDFAdapter(args[1],args[2]);
		try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(args[0])), 524288);
			String line;
			int i=0;
			while ((line = in.readLine()) != null) {
				if (i++==0) {
					System.out.println(line);
					continue;
				}
				String[] terms = line.split(" ");
				int idx1 = Integer.parseInt(terms[0]);
				int idx2 = Integer.parseInt(terms[1]);
				System.out.println(idx1+" "+idx2+" "+dist.score(idx1, idx2));
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}       		
	}

}
