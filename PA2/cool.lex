/*
 * CS164: Spring 2004
 * Programming Assignment 2
 *
 * The scanner definition for Cool.
 *
 */

import java_cup.runtime.Symbol;

%%

/* Code enclosed in %{ %} is copied verbatim to the lexer class definition.
 * All extra variables/methods you want to use in the lexer actions go
 * here.  Don't remove anything that was here initially.  */
%{
    // Max size of string constants
    static int MAX_STR_CONST = 1024;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    // Keep track of number of nestedly opened comment. Should be 0 or greater.
    private int openCommentCounter = 0;

    // For line numbers
    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
    
    void deleteEscape(StringBuffer toDelete) {
        for (int i = 0; i < toDelete.length(); i++) {
           char potential_backslash = toDelete.charAt(i);
           
            System.out.println("in method scope");
           if (potential_backslash == '\n' || potential_backslash == '\t')
               System.out.println("matched the newline.");
           if (potential_backslash == '\\') {
                char nextone = toDelete.charAt(i + 1);
                if (nextone == 'n' || nextone == 'b' || nextone == 't' || nextone == 'f')
                   {
                       System.out.println("in escape");
                       if (nextone == 'n') {
                     toDelete.setCharAt(i, '\n');
                     System.out.println(toDelete.charAt(i);
                     toDelete.deleteCharAt(i + 1);
                       }
                       else if (nextone == 'b') {
                     toDelete.setCharAt(i, '\b');
                     toDelete.deleteCharAt(i + 1);
                       }
                       else if(nextone == 't') {
                     toDelete.setCharAt(i, '\t');
                     toDelete.deleteCharAt(i + 1);
                       }
                       else if(nextone == 'f') {
                     toDelete.setCharAt(i, '\f');
                     toDelete.deleteCharAt(i + 1);
                       }
                    }
                else {
                    
                    System.out.println("in non escape");
                	toDelete.deleteCharAt(i);
                }
            }
            
        }
    }

    /* commentOpen is called when lexer sees '(*', it increments the
     * open comment counter.
     */
    void commentOpen () {
        openCommentCounter++;
    }
    
    /* commentClose is called when lexer sees '*)'.
     * It decrements the open comment counter and returns it.
     */
    int commentClose () {
        openCommentCounter--;
        return openCommentCounter;
    }

    /* getCommentCounter simply returns openCommentCounter
     * @return open comment counter
     */
    int getCommentCounter () {
        return openCommentCounter;
    }

    /*
     * Add extra field and methods here.
     */
%}


/*  Code enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here. */
%init{
    // empty for now
%init}

/*  Code enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work. */
%eofval{
    
/*  switch(yystate()) {
    case YYINITIAL:
        {   
            //return new Symbol(TokenConstants.TYPEID); }

	break;
	
	case STRING:
	    // error msg, EOF in string


/* If necessary, add code for other states here, e.g:
    case LINE_COMMENT:
	   ...
	   break;
 
    } */
    return new Symbol(TokenConstants.EOF);
%eofval}

/* Do not modify the following two jlex directives */
%class CoolLexer
%cup


/* This defines a new start condition for line comments.
 * .
 * Hint: You might need additional start conditions. */
%state LINE_COMMENT
%state STRING
%state COMMENT


/* Define lexical rules after the %% separator.  There is some code
 * provided for you that you may wish to use, but you may change it
 * if you like.
 * .
 * Some things you must fill-in (not necessarily a complete list):
 *   + Handle (* *) comments.  These comments should be properly nested.
 *   + Some additional multiple-character operators may be needed.  One
 *     (DARROW) is provided for you.
 *   + Handle strings.  String constants adhere to C syntax and may
 *     contain escape sequences: \c is accepted for all characters c
 *     (except for \n \t \b \f) in which case the result is c.
 * .
 * The complete Cool lexical specification is given in the Cool
 * Reference Manual (CoolAid).  Please be sure to look there. */
%%

<YYINITIAL>\n	 { curr_lineno++;  }
<YYINITIAL>\s+   {  }

<YYINITIAL>"(*"  { commentOpen(); yybegin(COMMENT); }

<COMMENT>"(*" { commentOpen(); }
<COMMENT>"*)" { if (commentClose() == 0) yybegin(YYINITIAL); }
<COMMENT>[^\n\*\)\(]*   { }
<COMMENT>[\*\)\(] { }
<COMMENT>\n   { curr_lineno++; }


<YYINITIAL>"*)" { System.out.println("Should raise an error here."); }


<YYINITIAL>"--"         { yybegin(LINE_COMMENT); }

<YYINITIAL>"(*"         { yybegin(NESTED_COMMENT); comment_depth++; }
<YYINITIAL>"*)"         { /* output ERROR msg */ }


<LINE_COMMENT>.*        { }
<LINE_COMMENT>\n        { ++curr_lineno; yybegin(YYINITIAL); }



<YYINITIAL>"=>"		{ return new Symbol(TokenConstants.DARROW); }





<YYINITIAL>[0-9][0-9]*  { /* Integers */
                          return new Symbol(TokenConstants.INT_CONST,
					    AbstractTable.inttable.addString(yytext())); }

<YYINITIAL>\"  { string_buf.setLength(0); yybegin(STRING); }
	
<STRING>[^\n\"]* { string_buf.append(yytext()); }
<STRING>\" { yybegin(YYINITIAL); deleteEscape(string_buf);  return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString())); } //this is for beauty"
<STRING>\n   { error here
<STRING>\0   { error here
<STRING>\\n  { escape here


<YYINITIAL>[Cc][Aa][Ss][Ee]	{ return new Symbol(TokenConstants.CASE); }
<YYINITIAL>[Cc][Ll][Aa][Ss][Ss] { return new Symbol(TokenConstants.CLASS); }
<YYINITIAL>[Ee][Ll][Ss][Ee]  	{ return new Symbol(TokenConstants.ELSE); }
<YYINITIAL>[Ee][Ss][Aa][Cc]	{ return new Symbol(TokenConstants.ESAC); }
<YYINITIAL>f[Aa][Ll][Ss][Ee]	{ return new Symbol(TokenConstants.BOOL_CONST, Boolean.FALSE); }
<YYINITIAL>[Ff][Ii]             { return new Symbol(TokenConstants.FI); }
<YYINITIAL>[Ii][Ff]  		{ return new Symbol(TokenConstants.IF); }
<YYINITIAL>[Ii][Nn]             { return new Symbol(TokenConstants.IN); }
<YYINITIAL>[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] { return new Symbol(TokenConstants.INHERITS); }
<YYINITIAL>[Ii][Ss][Vv][Oo][Ii][Dd] { return new Symbol(TokenConstants.ISVOID); }
<YYINITIAL>[Ll][Ee][Tt]         { return new Symbol(TokenConstants.LET); }
<YYINITIAL>[Ll][Oo][Oo][Pp]  	{ return new Symbol(TokenConstants.LOOP); }
<YYINITIAL>[Nn][Ee][Ww]		{ return new Symbol(TokenConstants.NEW); }
<YYINITIAL>[Nn][Oo][Tt] 	{ return new Symbol(TokenConstants.NOT); }
<YYINITIAL>[Oo][Ff]		{ return new Symbol(TokenConstants.OF); }
<YYINITIAL>[Pp][Oo][Oo][Ll]  	{ return new Symbol(TokenConstants.POOL); }
<YYINITIAL>[Tt][Hh][Ee][Nn]   	{ return new Symbol(TokenConstants.THEN); }
<YYINITIAL>t[Rr][Uu][Ee]	{ return new Symbol(TokenConstants.BOOL_CONST, Boolean.TRUE); }
<YYINITIAL>[Ww][Hh][Ii][Ll][Ee] { return new Symbol(TokenConstants.WHILE); }


<YYINITIAL> "self"    { return new Symbol(TokenConstants.OBJECTID); }

<YYINITIAL> "SLEF_TYPE"    { return new Symbol(TokenConstants.TYPEID); }


<YYINITIAL>[a-z][A-Za-z0-9_]* { return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }


<YYINITIAL>"+"			{ return new Symbol(TokenConstants.PLUS); }
<YYINITIAL>"/"			{ return new Symbol(TokenConstants.DIV); }
<YYINITIAL>"-"			{ return new Symbol(TokenConstants.MINUS); }
<YYINITIAL>"*"			{ return new Symbol(TokenConstants.MULT); }
<YYINITIAL>"="			{ return new Symbol(TokenConstants.EQ); }
<YYINITIAL>"<"			{ return new Symbol(TokenConstants.LT); }
<YYINITIAL>"."			{ return new Symbol(TokenConstants.DOT); }
<YYINITIAL>"~"			{ return new Symbol(TokenConstants.NEG); }
<YYINITIAL>","			{ return new Symbol(TokenConstants.COMMA); }
<YYINITIAL>";"			{ return new Symbol(TokenConstants.SEMI); }
<YYINITIAL>":"			{ return new Symbol(TokenConstants.COLON); }
<YYINITIAL>"("			{ return new Symbol(TokenConstants.LPAREN); }
<YYINITIAL>")"			{ return new Symbol(TokenConstants.RPAREN); }
<YYINITIAL>"@"			{ return new Symbol(TokenConstants.AT); }
<YYINITIAL>"}"			{ return new Symbol(TokenConstants.RBRACE); }
<YYINITIAL>"{"			{ return new Symbol(TokenConstants.LBRACE); }

<YYINITIAL>"->"			{ return new Symbol(TokenConstants.ASSIGN); }


.                { /*
                    *  This should be the very last rule and will match
                    *  everything not matched by other lexical rules.
                    */
                   System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
