package edu.stanford.cads.oneoffs;

import java.io.IOException;
import java.io.StringReader;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;


import java.util.*;

import org.apache.lucene.search.Hits;
import org.apache.lucene.search.Query;
import org.apache.lucene.document.Field;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.document.Document;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.MultiFieldQueryParser;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.search.spell.SpellChecker;
import org.apache.lucene.search.spell.LuceneDictionary;
import org.apache.lucene.store.Directory;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.PorterStemFilter;
import org.apache.lucene.analysis.StopFilter;
import org.apache.lucene.analysis.TokenFilter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.Tokenizer;
import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.ISOLatin1AccentFilter;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.standard.StandardTokenizer;
import org.apache.lucene.analysis.standard.StandardFilter;
import org.apache.lucene.analysis.ngram.NGramTokenFilter;
import org.apache.lucene.analysis.ngram.EdgeNGramTokenFilter;



/*
 * 27 September 2007
 * Added output for edge weights and changed to look at the top 100
 * similar vertices unless the score delta changes below 0.25
 */

class RemovePunctuationTokenizer extends Tokenizer {
    public RemovePunctuationTokenizer (Reader reader) {
        input = reader;
    }
    
    private int offset = 0, bufferIndex=0, dataLen=0;
    private final static int MAX_WORD_LEN = 255;
    private final static int IO_BUFFER_SIZE = 1024;
    private final char[] buffer = new char[MAX_WORD_LEN];
    private final char[] ioBuffer = new char[IO_BUFFER_SIZE];
    
    public final Token next() throws java.io.IOException {
        int length = 0;
        int start = offset;
        while (true) {
            final char c;

            offset++;
            if (bufferIndex >= dataLen) {
                dataLen = input.read(ioBuffer);
                bufferIndex = 0;
            };
            if (dataLen == -1) {
                if (length > 0)
                    break;
                else
                    return null;
            }
            else
                c = (char) ioBuffer[bufferIndex++];
          
            if (Character.isLetterOrDigit(c)) {        
                // if it's a letter

                if (length == 0)              // start of token
                    start = offset-1;

                // buffer it
                buffer[length++] = c;             

                // buffer overflow!
                if (length == MAX_WORD_LEN)       
                    break;    

            } else if (!Character.isWhitespace(c)) { 
                // it isn't whitespace
                // just skip it
            } else if (length > 0) {
                // so the only thing that reaches here is whitespace
                break;                    // return 'em
            }

        }
        
        return new Token(new String(buffer, 0, length), start, offset-1);
    }
}
class WordNetTokenFilter extends TokenFilter {
    ArrayList<String> words = new ArrayList<String>();
    String cat ="";
    WordNetTokenFilter(TokenStream input) {
        super(input);
        Token t = null;
        try {
        while (null != (t = input.next())) {
            if (t.termText()==null) continue;
            cat += t.termText();
            words.addAll(WordNetAdapter.getInstance().getSynonyms(t.termText()));
        }
        }catch (IOException e) {e.printStackTrace();}   
    }
    public Token next() {
        if (words.size()==0) return null;
        String w = words.remove(0);
        System.out.println(cat+":"+w);
        return new Token(w, 0, 0);
    }
}
class LCSHGramAnalyzer extends Analyzer {
    
    public final TokenStream tokenStream(String fieldName, Reader reader) {
        TokenStream result = new RemovePunctuationTokenizer(reader);
        result = new StandardFilter(result);
        result = new LowerCaseFilter(result);
        result = new ISOLatin1AccentFilter(result);
        if ("head3".compareTo(fieldName) == 0) {
            result = new EdgeNGramTokenFilter(result, EdgeNGramTokenFilter.Side.FRONT, 2, 3);
        } else if ("head4".compareTo(fieldName) == 0) {
            result = new EdgeNGramTokenFilter(result, EdgeNGramTokenFilter.Side.FRONT, 4, 4);
        } else if ("tail3".compareTo(fieldName) == 0) {
            result = new EdgeNGramTokenFilter(result, EdgeNGramTokenFilter.Side.BACK, 2, 3);
        } else if ("tail4".compareTo(fieldName) == 0) {
            result = new EdgeNGramTokenFilter(result, EdgeNGramTokenFilter.Side.BACK, 4, 4);
        } else if ("gram3".compareTo(fieldName) == 0) {
            result = new NGramTokenFilter(result, 2, 3);
        } else if ("gram4".compareTo(fieldName) == 0) {
            result = new NGramTokenFilter(result, 4, 4);
        }
        return result;
    }   
}

abstract class MatchSuggestions {
    public abstract Analyzer getAnalyzer();
    public abstract QueryParser getQueryParser();
    public abstract Document createDocument(int id, String name);
}

class StandardSuggestions extends MatchSuggestions {
    public Analyzer getAnalyzer() {
        return new StandardAnalyzer();
    }
    public QueryParser getQueryParser() {
        return new QueryParser("name", getAnalyzer());
    }
    public Document createDocument(int id, String name) {
        Document d = new Document();
        d.add(new Field("id", "" + id, Field.Store.YES, Field.Index.NO));
        d.add(new Field("name", name, Field.Store.YES, Field.Index.TOKENIZED));
        return d;
    }
}

class DropPunctuationSuggestions extends MatchSuggestions {
    static Set<String> stopWords = new HashSet<String>();
    public static String filter(String input) {
        if (stopWords.size()==0) return input;
        String[] ws = input.split(" ");     
        String out="";
        for (String w:ws) {
            if (!stopWords.contains(w)) out += w +" ";
        }
        return out.trim();
    }
    public static void initStopWord(String filename) {
        try {           
            // open the list of terms 
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(new FileInputStream(filename)));
            String line="";
            while ((line = in.readLine()) != null) {    
                stopWords.add(line);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
            
    }
    public Analyzer getAnalyzer() { 
        return new Analyzer() { 
            public final TokenStream tokenStream(String fieldName, Reader reader) {
                TokenStream result = new RemovePunctuationTokenizer(reader);
                result = new StandardFilter(result);
                result = new LowerCaseFilter(result);
                result = new StopFilter(result,stopWords,true);
                //result = new PorterStemFilter(result);
                //result = new WordNetTokenFilter(result);
                return result;
            }
        };
    }

    public QueryParser getQueryParser() {
        return new QueryParser("name", getAnalyzer());
    }
    public Document createDocument(int id, String name) {
        Document d = new Document();
        d.add(new Field("id", "" + id, Field.Store.YES, Field.Index.NO));
        d.add(new Field("name", name, Field.Store.YES, Field.Index.TOKENIZED));
        return d;
    }
}

class NGramSuggestions extends MatchSuggestions {
    public Analyzer getAnalyzer() { 
        return new LCSHGramAnalyzer();
    }
    public QueryParser getQueryParser() {
        HashMap<String,Float> boosts = new HashMap<String,Float>();
        boosts.put("name", 1.0f);
        boosts.put("head3", 0.9f);
        boosts.put("head4", 1.0f);
        boosts.put("tail3", 0.9f);
        boosts.put("tail4", 1.0f);
        boosts.put("gram3", 0.9f);
        boosts.put("gram4", 1.0f);
        return new MultiFieldQueryParser(new String[]{"name","head3","head4","tail3","tail4","gram3","gram4"}, 
                getAnalyzer(), boosts);
    }
    public Document createDocument(int id, String name) {
        Document d = new Document();
        d.add(new Field("id", "" + id, Field.Store.YES, Field.Index.NO));
        d.add(new Field("name", name, Field.Store.YES, Field.Index.TOKENIZED));
        d.add(new Field("head3", name, Field.Store.NO, Field.Index.TOKENIZED));
        d.add(new Field("head4", name, Field.Store.NO, Field.Index.TOKENIZED));
        d.add(new Field("tail3", name, Field.Store.NO, Field.Index.TOKENIZED));
        d.add(new Field("tail4", name, Field.Store.NO, Field.Index.TOKENIZED));
        d.add(new Field("gram3", name, Field.Store.NO, Field.Index.TOKENIZED));
        d.add(new Field("gram4", name, Field.Store.NO, Field.Index.TOKENIZED));
        return d;
    }
}




/**
 * This class implements a Lucene text-based matching between the 
 * Wikipedia categories and the LC Subject Headings.
 * 
 * @author David Gleich
 *
 */
public class LuceneWikipedia2LCSH {
    
    public static Directory buildTermIndex(String path, MatchSuggestions m)
    {
        // Construct a RAMDirectory to hold the in-memory representation
        // of the index.
        RAMDirectory idx = new RAMDirectory();

        try {
            // create the Lucene index writer
            IndexWriter writer = new IndexWriter(idx, m.getAnalyzer(), true);
            
            // open the string database
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(new FileInputStream(path)), 524288);
            String line;
            int i=0;
            while ((line = in.readLine()) != null) {
                writer.addDocument(m.createDocument(i,line));
                i++;
            }
            writer.optimize();
            writer.close();         
        } catch (IOException ioe) {
            System.err.println(ioe.toString());
            ioe.printStackTrace();
            System.exit(-1);
        } 
        
        return idx;
    }
    
    

    static SoftTFIDFAdapter dist;
    /**
     * PopulateHitInfoSet take Hits object and populate the Set<HitInfo>
     * @param mult is used to multiple the score of non exact match (not used anymore).
     * @param path
     */     
    public static int queryEval (Hits h, String line, double mult, Set<HitInfo> hitSet) throws IOException{
        boolean exact = false;              
        for (int j = 0; j < Math.min(h.length(), 100); ++j) {
            if (h.doc(j).get("name").compareToIgnoreCase(line) == 0) {
                //hits.incrementCount(h.doc(j).get("name"),1);
                nn++;
                hitSet.add(new HitInfo(h.doc(j).get("id"),h.doc(j).get("name"),1));
                //System.out.print("\t"+h.doc(j).get("name")+","+h.doc(j).get("id")+"*\n");
                exact = true;
                break;
            }
        }
        float score = 1.0f;
        float delta = 0.0f;
        for (int j = 0; j < Math.min(h.length(), exact? kMaxHitsToAddIfExact : kMaxHitsToAddIfNotExact); ++j) {
        if (j > 0) {
            delta = score - h.score(j);
        }
        score = h.score(j);
            if (delta < kAllowableDelta) {
                if (hitSet.contains(h.doc(j).get("name"))) continue;                
                hitSet.add(new HitInfo(h.doc(j).get("id"), h.doc(j).get("name"), score* mult));
                //System.out.print("\t" + h.doc(j).get("name")+"," + 
                //h.doc(j).get("id") + "," + score*mult);               
                //hits.incrementCount(h.doc(j).get("name"),1);
                nn++;
            } else {
            break;
        }
        }
        return h.length();
    }
    /**
     * Write a set of term suggestions to stdout for each line in path
     * based on a Lucene search checker
     * @param idx the Lucene index
     * @param path
     */ 
    public static void writeTermSuggestions(Directory idx, String path, MatchSuggestions m) {
        int i=0;
        String line;
        DecimalFormat twoPlaces = new DecimalFormat("0.00");
        try {
            IndexSearcher searcher = new IndexSearcher(idx);
            QueryParser parser = m.getQueryParser();
            
            parser.setPhraseSlop(3);
            
            // open the list of terms 
            BufferedReader in = new BufferedReader(
                    new InputStreamReader(new FileInputStream(path)), 524288);

            while ((line = in.readLine()) != null) {
                int hitLength=0;
                Query q = parser.parse("\"" + QueryParser.escape(line) + "\"");
                Hits h = searcher.search(q);                
                //System.out.print("" + i + "\t" + line);
                Set<HitInfo> hitSet = new HashSet<HitInfo>();
                hitLength+=queryEval(h, line, 1, hitSet);               
                if (h.length() < kMinHitsForSkippingQueryExpansion) {
                    String[] words = line.split(" ");
                    ArrayList<String> synonyms = new ArrayList<String>();
                    for (String w:words) {
                        synonyms.addAll(WordNetAdapter.getInstance().getSynonyms(w));
                    }
                    for (String w:synonyms) {
                        if (w.length()==0) continue;
                        if (w.compareTo("OR")==0) continue;
                        if (w.compareTo("AND")==0) continue;
                        Hits hh = searcher.search(parser.parse(QueryParser.escape(w)));
                        hitLength+=queryEval(hh,line,0.5,hitSet);
                        
                    }
                }
                //System.out.println("");
                // Recalculate the score for each HitInfo in the hitSet.
                System.out.print("" + i + "\t" + line);
                boolean first=true;
                for (HitInfo hi:hitSet) {
                    hi.score=dist.score(line, hi.name);
                    if (hi.score>1) {
                        // in some rare occasion, SoftTFIDF get score >1.
                        // I don't know why, so I just make it less than 1.
                        hi.score = 1 - hi.score + 1;
                        }
                    System.out.print("\t"+hi.name+"|"+twoPlaces.format(hi.score)+"|"+hi.id);
                }
                System.out.println();
                
                i++;
                if (hitLength==0) n0++;
            }
        } catch (Exception e) {
            System.err.println(e.toString());
            e.printStackTrace();
            System.exit(-1);
        }
        /*
        System.out.println("Matching Stats From S -> T");
        System.out.println("# source node deg = 0 : "+n0);
        System.out.println("sum of target node deg : "+nn);
        System.out.println("# target nodes deg >0 : "+hits.size());
        System.out.println("sum of target node deg : "+hits.totalCount());
        PriorityQueue<String> pq = hits.asPriorityQueue();
        Counter<Integer> hist = new Counter<Integer>();
        System.out.println("Histogram");
        while (pq.hasNext()) {
            String cat = pq.next();
            double count = hits.getCount(cat);
            //System.out.println(cat+"\t"+count);
            hist.incrementCount((int)count, 1.0);
        }
        PriorityQueue<Integer> pq2 = hist.asPriorityQueue();
        while (pq2.hasNext()) {
            int count = pq2.next();
            System.out.println(count+" "+hist.getCount(count));
        }
        */
    }
    static int n0=0,nn=0,nk=0;
    static int kMinHitsForSkippingQueryExpansion = 1;
    static double kAllowableDelta = 0.35;
    static int kMaxHitsToAddIfNotExact = 20;
    static int kMaxHitsToAddIfExact = 10;
    //static Counter<String> hits = new Counter<String>();
    public static float timeInSecs(long millis) {
        return (float)millis/1000.0f;
    }

    /**
     * The main driver
     * @param args the command line arguments
     * args[0] is the list of Wikipedia categories
     * args[1] is the list of LC subject headings
     */
    
    public static void main(String[] args) throws Exception {
        if (args.length != 2 && args.length != 3) {
            System.err.println("usage: wikipedia_category_file lcsh_file [standard|droppunct|grams]");
        }       
        String wc_path = args[0];
        String lcsh_path = args[1];
        String stopword= System.getProperty("stopword","");
        if (stopword.length()>2)
            DropPunctuationSuggestions.initStopWord(stopword);
        WordNetAdapter.init("/cads/data/wordnet");
        dist = new SoftTFIDFAdapter(wc_path, lcsh_path);
        long start, end;        
        MatchSuggestions m = new DropPunctuationSuggestions();
        
        if (args.length == 3) {
            String suggestion_type = args[2];
            if (suggestion_type.compareTo("standard") == 0) {
                m = new StandardSuggestions();
            } else if (suggestion_type.compareTo("droppunct") == 0) {
                // do nothing, because it's already set
            } else if (suggestion_type.compareTo("ngram") == 0) {
                m = new NGramSuggestions();
            } else {
                throw new Exception("Unknown option \'" + suggestion_type + "\" given for match suggestion type.");
            }
        }
        
        System.err.println("Building term index... ");
        start = System.currentTimeMillis();
        Directory dir = buildTermIndex(lcsh_path, m);
        end = System.currentTimeMillis();
        System.err.println(" ... done! (" + timeInSecs(end-start) + " secs.)");
        
        System.err.println("Suggesting terms ... ");
        start = System.currentTimeMillis();
        writeTermSuggestions(dir, wc_path, m);
        end = System.currentTimeMillis();
        System.err.println(" ... done! (" + timeInSecs(end-start) + " secs.)");

    }
}

class HitInfo {
    HitInfo(String id, String name, double score) {
        this.id=Integer.parseInt(id);
        this.name=name;
        this.score=score;       
    }
    public int id;
    public String name;
    public double score;
    public int hashCode() {return id;}
    public boolean equals(Object h) {return ((HitInfo)h).id==id;}
}
