package edu.stanford.cads.oneoffs;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import java.util.SortedSet;


import edu.mit.jwi.dict.*;
import edu.mit.jwi.item.IIndexWord;
import edu.mit.jwi.item.IWord;
import edu.mit.jwi.item.IWordID;
import edu.mit.jwi.item.PartOfSpeech;
import edu.mit.jwi.morph.WordnetStemmer;

public class WordNetAdapter {
	IDictionary dict;
	WordnetStemmer stemmer;
	WordNetAdapter(String path) {
		URL url = null;
		try {
			url = new URL("file", null, path);
		} catch (Exception e) { e.printStackTrace();}
		if (url == null) return;
		dict = new Dictionary(url);
		dict.open();
		stemmer = new WordnetStemmer(dict);
	}
	public Set<String> getSynonyms(String word) {		
		Set<String> synonyms = new HashSet<String>();
		synonyms.add(word);
		SortedSet<String> roots = stemmer.getRoots(word);
		if (roots == null) return synonyms;
		synonyms.addAll(roots);
		ArrayList<PartOfSpeech> poses= new ArrayList<PartOfSpeech>();
		poses.add(PartOfSpeech.NOUN);
		poses.add(PartOfSpeech.ADJECTIVE);
		for (String root:roots) {
			for (PartOfSpeech pos:poses) {
				IIndexWord idxWord = dict.getIndexWord(root, pos);
				if (idxWord == null) continue;
				IWordID[] wordIDs = idxWord.getWordIDs();
				for (IWordID wid:wordIDs) {
					IWord[] syns = dict.getSynset(wid.getSynsetID()).getWords();
					for (IWord s:syns) {
						synonyms.add(s.getLemma().replace('_', ' '));
					}					
				}
			}			
		}
		return synonyms;
	}
	static WordNetAdapter me;
	static void init(String path) {
		me = new WordNetAdapter(path);
	}
	public static WordNetAdapter getInstance() {
		return me;
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		WordNetAdapter.init("/dict");
		WordNetAdapter wna = WordNetAdapter.getInstance(); 
		Set<String> list = wna.getSynonyms("dog");
		for (String w:list) {
			System.out.println(w);
		}
	}

}
