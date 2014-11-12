package edu.stanford.cads.oneoffs;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import com.wcohen.ss.BasicStringWrapperIterator;
import com.wcohen.ss.JaroWinkler;
import com.wcohen.ss.SoftTFIDF;
import com.wcohen.ss.tokens.SimpleTokenizer;
class MyTuple {
	public MyTuple(String cat, double score, int index) {
		this.cat =cat;
		this.score = score;
		this.idx = index;
	}
	public String toString() {		
		return cat+","+idx+","+score;
	}
	String cat;
	double score;
	int idx;
}

public class SoftTFIDFAdapter {
	SoftTFIDF distance;
	ArrayList<String> cat2 = new ArrayList<String>();
	ArrayList<String> cat1 = new ArrayList<String>();
	static String parse(String input) {
		input=input.replace(",", "");
		input=input.replace("(", "");
		input=input.replace(")", "");
		return DropPunctuationSuggestions.filter(input);
		
	}
	public SoftTFIDFAdapter(String path1, String path2) {
		 // create a SoftTFIDF distance learner
	com.wcohen.ss.api.Tokenizer tokenizer = new SimpleTokenizer(false,true);
       double minTokenSimilarity = 0.8;
       distance = new SoftTFIDF(tokenizer,new JaroWinkler(),0.8);
       
       // train the distance on some strings - in general, this would
       // be a large corpus of existing strings, so that some
       // meaningful frequency estimates can be accumulated.  for
       // efficiency, you train on an iterator over StringWrapper
       // objects, which are produced with the 'prepare' function.

       List list = new ArrayList();        
       long start,end;
       System.err.print("Training SoftTFIDF...");
	   start = System.currentTimeMillis();
       
       
   	try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(path1)), 524288);
			String line;
			while ((line = in.readLine()) != null) {
				line = parse(line);
				cat1.add(line);
				list.add(distance.prepare(line));
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}        
/*
       for (int i=0; i<corpus.length; i++) {
           list.add( distance.prepare(corpus[i]) );
       }
       */
       distance.train( new BasicStringWrapperIterator(list.iterator()) );
       list.clear();
       // now use the distance metric on some examples
   	try {
			BufferedReader in = new BufferedReader(
					new InputStreamReader(new FileInputStream(path2)), 524288);
			String line;
			while ((line = in.readLine()) != null) {
				line = parse(line);
				cat2.add(line);
				list.add(distance.prepare(line));
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		distance.train( new BasicStringWrapperIterator(list.iterator()) );	
		end = System.currentTimeMillis();
		System.err.println(" (" + timeInSecs(end-start) + " secs.)");        
		start = System.currentTimeMillis();				
	}
	public static float timeInSecs(long millis) {
		return (float)millis/1000.0f;
	}
	public ArrayList<MyTuple> getMatches(String query, double minScore) {
		ArrayList<MyTuple> list = new ArrayList<MyTuple>();
		for (int idx=0; idx<cat2.size();idx++) {
			String w2 = cat2.get(idx);
			double val=myCompare(query, w2, false);
			if (val>=minScore) {
				list.add(new MyTuple(w2,val,idx));
			}
		}
		return list;
	}
	double score(String s, String t) {
		return distance.score(distance.prepare(s), distance.prepare(t));
	}
	double score (int idx1, int idx2) {
		return distance.score(distance.prepare(cat1.get(idx1)), distance.prepare(cat2.get(idx2)));
	}
    double myCompare(String s, String t, boolean write)
    {
        // compute the similarity
        //double d = distance.score(s,t);
    	double e = distance.score( distance.prepare(s), distance.prepare(t) );
        // print it out
        if (write) {
        System.out.println("========================================");
        System.out.println("String s:  '"+s+"'");
        System.out.println("String t:  '"+t+"'");
        System.out.println("Similarity: "+e);
		
        // a sort of system-provided debug output
        System.out.println("Explanation:\n" + distance.explainScore(s,t));
        }
        // this is equivalent to d, above, but if you compare s to
        // many strings t1, t2, ... it's a more efficient to only
        // 'prepare' s once.

        
        return e;
    }	
}