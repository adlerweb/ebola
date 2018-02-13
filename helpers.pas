unit helpers;

{$mode objfpc}{$H+}

interface


uses
  Classes, FileUtil, SysUtils;

function AnsiReplaceAll(s,OldSubStr,NewSubStr:String):String;
function isNumeric(s:string):boolean;
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
function GetRight(s, sDelim :String):String;
function GetLeft(s, sDelim :String):String;
function ClearTitel(S :String):String;
function ClearUrl(S :String):String;
function ClearHeading(S :String):String;
function ClearSpezChar(S : string):string;
function isValidItem(S : string):boolean;
function inAusnahme(S : string):boolean;
function RepairTags(s : string):string;
function ClearTags(s : string):string;
function UTF8ToChar( s: string):string;
function HTML4ToChar( s: string):string;
function TagStop(iStart:integer;s:string):integer;
function TagString(iStart:integer;s:string):string;
function ChangeOldLink(S :String):String;
function GetKapCount(sFile:string):integer;
function GetAdresse(sFile:string):string;
procedure CreateAuthorList(sSrcDir, sAutorfile: string; sSource: string);    // 'Gutenberg' oder 'Zeno'
procedure CopyOne(sSrc, sDst: string);
procedure MakeDir(sDir: string);
procedure CopyAll(sSrcDir, sDstDir: string);
procedure ClearDir(sDir: string);
function DoFilenamecomp(S :String):String;
procedure DeleteFiles(Name: string);
function DelTags(s:String):String;

var
   sOutputDir  : string;

type
   rBook=record
      sAutor, sTitel, sUrl : string;
      sType, sDir : string;
  end;
  pBook = ^rBook;



implementation
var sStripAddress:string;
//-------------------------------------------------------------------------------------------
function DelTags(s:String):String;
var i : integer;
    bCopy : boolean;
begin
     result := '';
     bCopy := true;
     for i:=1 to length(s) do begin
         if (s[i]='<') then bCopy := false;
         if (s[i]='>') then begin
             bCopy := true;
         end else if (bCopy) then result := result + s[i];
     end;
end;

//-------------------------------------------------------------------------------------------
function AnsiReplaceAll(s,OldSubStr,NewSubStr:String):String;
var  P: integer;
begin
       P:=Pos(OldSubStr, NewSubStr);
      if P = 0 then begin
        P:=Pos(OldSubStr, S);
        while P > 0 do begin
          S:=Copy(S, 1, P-1)+NewSubStr+Copy(S, P+Length(OldSubStr), Length(S));
          P:=Pos(OldSubStr, S);
        end;
      end;
      Result:=S;
end;
//-------------------------------------------------------------------------------------------
function isNumeric(s:string):boolean;
var i:integer;
begin
     result := true;
     for i:=1 to Length(s) do begin
         if (not (s[i] in ['0'..'9'])) then begin
            result := false;
            break;
         end;
     end;
end;
//-------------------------------------------------------------------------------------------
procedure Split (const Delimiter: Char; Input: string; const Strings: TStrings);
begin
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   Strings.StrictDelimiter := true;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
end;
//-------------------------------------------------------------------------------------------
function GetRight(s, sDelim :String):String;
var  P: integer;
begin
      P:=Pos(sDelim, s);
      if P <> 0 then begin
         //S:=Copy(S, P+1, length(s));
         S:=Copy(S, P+length(sDelim), length(s));
      end;
      Result:=S;
end;
//-------------------------------------------------------------------------------------------
function GetLeft(s, sDelim :String):String;
var  P: integer;
begin
      P:=Pos(sDelim, s);
      if P <> 0 then begin
          S:=Copy(S, 1, P-1)
      end;
      Result:=S;
end;
//-------------------------------------------------------------------------------------------
function TagStop(iStart:integer;s:string):integer;
var i : integer;
begin
    Result:=Length(s);
    for i:=iStart to Length(s) do begin
        if (s[i]='>') then begin
           Result:=i;
           break;
        end;
    end;
end;
//-------------------------------------------------------------------------------------------
function TagString(iStart:integer;s:string):string;
var j : integer;
begin
     j := TagStop(iStart,s);
     Result := Copy(s,iStart,j-iStart);
end;
//-------------------------------------------------------------------------------------------
function RepairTags(s : string):string;
var iH,iJ : integer;
    stmp  : string;
    stmp2 : string;
begin
     s:=AnsiReplaceAll(s,'<br>','<br />');
     s:=AnsiReplaceAll(s,'</br>','<br />');
     s:=AnsiReplaceAll(s,'<br />'#13,'<br />');
     iH:=Pos('<hr',s);
     if (iH>0) then s := AnsiReplaceAll(s,TagString(iH,s),'<hr /');
     iH:=Pos('<img',s);
     if (iH>0) then begin
        iJ := TagStop(iH,s);
        //###s := '<p>' + AnsiReplaceAll('<center>'+Copy(s,iH,iJ-iH+1) + '</img></center>' + Copy(s,iJ+1,65535),'<img src="bilder/','<img src="images/');
        stmp:= Copy(s,iH,iJ-iH+1);
        // alt-Attribut zwingend erforderlich
        if Pos('alt=', stmp) = 0 then stmp:= GetLeft(stmp, '>')+ ' alt="" >' + GetRight(stmp, '>');

        // entferne ungültiges vspace-Attribut; z.B. vspace="20"
        if Pos('vspace="', stmp) > 0 then begin
           stmp2 := GetRight(stmp, 'vspace="');
           stmp := GetLeft(stmp, 'vspace="') + GetRight(stmp2, '"');
        end;

        s := GetLeft(s,'<img') + AnsiReplaceAll(stmp + '</img>' + Copy(s,iJ+1,65535),'<img src="bilder/','<img src="images/');

        iH := Pos('<img src="images/',s);
        if (iH=0) then begin
           s := AnsiReplaceAll(s,'<img src="','<??? src="images/');
           s := AnsiReplaceAll(s,'<???','<img');
        end;
     end;
     result := s;
end;
//-------------------------------------------------------------------------------------------
function ClearTags(s : string):string;
begin
  s:=AnsiReplaceAll(s,'<li class="hide">','');
  s:=AnsiReplaceAll(s,'</div>','');
  s:=AnsiReplaceAll(s,'</a>','');
  s:=AnsiReplaceAll(s,'<a href="/autor/','http://gutenberg.spiegel.de/autor/');
  s:=AnsiReplaceAll(s,'<a href="/Literatur/','http://www.zeno.org/Literatur/');
  s:=AnsiReplaceAll(s,'">','*');    //delimiter between url and name
  s:=AnsiReplaceAll(s,'<br/>','#'); //delimiter between pairs of url and name
  s:=AnsiReplaceAll(s,':<i>','');
  s:=AnsiReplaceAll(s,'<i>','');
  s:=AnsiReplaceAll(s,'<p>','');
  s:=AnsiReplaceAll(s,'<ul>','');
  s:=AnsiReplaceAll(s,'<li>','');
  s:=AnsiReplaceAll(s,'</li>','');
  s:=AnsiReplaceAll(s,'<b>','');
  s:=AnsiReplaceAll(s,'</b>','');
  s:=AnsiReplaceAll(s,'<a href="','');
  s:=AnsiReplaceAll(s,'&amp;','und');   //&
  s:=AnsiReplaceAll(s,'../../','../');
  s:=AnsiReplaceAll(s,'        ../','http://gutenberg.spiegel.de/');
  s:=AnsiReplaceAll(s,'      ../','http://gutenberg.spiegel.de/');
  s:=AnsiReplaceAll(s,'../','http://gutenberg.spiegel.de/');
  s:=AnsiReplaceAll(s,#220+':','');
  s:=AnsiReplaceAll(s,'&#8211;','-');
  {$IfDef WINDOWS}
  s:=AnsiReplaceAll(s,#223,'ss');     //ß
  {$EndIf}
  s:=AnsiReplaceAll(s,#187,'');      //»
  s:=AnsiReplaceAll(s,#171,'');      //«
  s:=AnsiReplaceAll(s,#169+' ','');
  s:=AnsiReplaceAll(s,'( ','(');
  s:=AnsiReplaceAll(s,'&#8250;','');    //>
  s:=AnsiReplaceAll(s,'&#8249;','');   //<

  result := s;
end;

//------------------------------------------------
// replace UTF8 (hex.) to character
// Quelle: http://www.utf8-chartable.de/
function UTF8ToChar(s : string):string;
begin
  s:=AnsiReplaceAll(s,'%C2%A1','¡');     //INVERTED EXCLAMATION MARK
  s:=AnsiReplaceAll(s,'%C2%A2','¢');     //CENT SIGN
  s:=AnsiReplaceAll(s,'%C2%A3','£');     //POUND SIGN
  s:=AnsiReplaceAll(s,'%C2%A4','¤');     //CURRENCY SIGN
  s:=AnsiReplaceAll(s,'%C2%A5','¥');     //YEN SIGN
  s:=AnsiReplaceAll(s,'%C2%A6','¦');     //BROKEN BAR
  s:=AnsiReplaceAll(s,'%C2%A7','§');     //SECTION SIGN
  s:=AnsiReplaceAll(s,'%C2%A8','¨');     //DIAERESIS
  s:=AnsiReplaceAll(s,'%C2%A9','©');     //COPYRIGHT SIGN
  s:=AnsiReplaceAll(s,'%C2%AA','ª');     //FEMININE ORDINAL INDICATOR
  s:=AnsiReplaceAll(s,'%C2%AB','«');     //LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
  s:=AnsiReplaceAll(s,'%C2%AC','¬');     //NOT SIGN
  s:=AnsiReplaceAll(s,'%C2%AD','­');     //SOFT HYPHEN
  s:=AnsiReplaceAll(s,'%C2%AE','®');     //REGISTERED SIGN
  s:=AnsiReplaceAll(s,'%C2%AF','¯');     //MACRON
  s:=AnsiReplaceAll(s,'%C2%B0','°');     //DEGREE SIGN
  s:=AnsiReplaceAll(s,'%C2%B1','±');     //PLUS-MINUS SIGN
  s:=AnsiReplaceAll(s,'%C2%B2','²');     //SUPERSCRIPT TWO
  s:=AnsiReplaceAll(s,'%C2%B3','³');     //SUPERSCRIPT THREE
  s:=AnsiReplaceAll(s,'%C2%B4','´');     //ACUTE ACCENT
  s:=AnsiReplaceAll(s,'%C2%B5','µ');     //MICRO SIGN
  s:=AnsiReplaceAll(s,'%C2%B6','¶');     //PILCROW SIGN
  s:=AnsiReplaceAll(s,'%C2%B7','·');     //MIDDLE DOT
  s:=AnsiReplaceAll(s,'%C2%B8','¸');     //CEDILLA
  s:=AnsiReplaceAll(s,'%C2%B9','¹');     //SUPERSCRIPT ONE
  s:=AnsiReplaceAll(s,'%C2%BA','º');     //MASCULINE ORDINAL INDICATOR
  s:=AnsiReplaceAll(s,'%C2%BB','»');     //RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
  s:=AnsiReplaceAll(s,'%C2%BC','¼');     //VULGAR FRACTION ONE QUARTER
  s:=AnsiReplaceAll(s,'%C2%BD','½');     //VULGAR FRACTION ONE HALF
  s:=AnsiReplaceAll(s,'%C2%BE','¾');     //VULGAR FRACTION THREE QUARTERS
  s:=AnsiReplaceAll(s,'%C2%BF','¿');     //INVERTED QUESTION MARK
  s:=AnsiReplaceAll(s,'%C3%80','À');     //LATIN CAPITAL LETTER A WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%81','Á');     //LATIN CAPITAL LETTER A WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%82','Â');     //LATIN CAPITAL LETTER A WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%83','Ã');     //LATIN CAPITAL LETTER A WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%84','Ä');     //LATIN CAPITAL LETTER A WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%85','Å');     //LATIN CAPITAL LETTER A WITH RING ABOVE
  s:=AnsiReplaceAll(s,'%C3%86','Æ');     //LATIN CAPITAL LETTER AE
  s:=AnsiReplaceAll(s,'%C3%87','Ç');     //LATIN CAPITAL LETTER C WITH CEDILLA
  s:=AnsiReplaceAll(s,'%C3%88','È');     //LATIN CAPITAL LETTER E WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%89','É');     //LATIN CAPITAL LETTER E WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%8A','Ê');     //LATIN CAPITAL LETTER E WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%8B','Ë');     //LATIN CAPITAL LETTER E WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%8C','Ì');     //LATIN CAPITAL LETTER I WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%8D','Í');     //LATIN CAPITAL LETTER I WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%8E','Î');     //LATIN CAPITAL LETTER I WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%8F','Ï');     //LATIN CAPITAL LETTER I WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%90','Ð');     //LATIN CAPITAL LETTER ETH
  s:=AnsiReplaceAll(s,'%C3%91','Ñ');     //LATIN CAPITAL LETTER N WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%92','Ò');     //LATIN CAPITAL LETTER O WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%93','Ó');     //LATIN CAPITAL LETTER O WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%94','Ô');     //LATIN CAPITAL LETTER O WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%95','Õ');     //LATIN CAPITAL LETTER O WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%96','Ö');     //LATIN CAPITAL LETTER O WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%97','×');     //MULTIPLICATION SIGN
  s:=AnsiReplaceAll(s,'%C3%98','Ø');     //LATIN CAPITAL LETTER O WITH STROKE
  s:=AnsiReplaceAll(s,'%C3%99','Ù');     //LATIN CAPITAL LETTER U WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%9A','Ú');     //LATIN CAPITAL LETTER U WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%9B','Û');     //LATIN CAPITAL LETTER U WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%9C','Ü');     //LATIN CAPITAL LETTER U WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%9D','Ý');     //LATIN CAPITAL LETTER Y WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%9E','Þ');     //LATIN CAPITAL LETTER THORN
  s:=AnsiReplaceAll(s,'%C3%9F','ß');     //LATIN SMALL LETTER SHARP S
  s:=AnsiReplaceAll(s,'%C3%A0','à');     //LATIN SMALL LETTER A WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%A1','á');     //LATIN SMALL LETTER A WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%A2','â');     //LATIN SMALL LETTER A WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%A3','ã');     //LATIN SMALL LETTER A WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%A4','ä');     //LATIN SMALL LETTER A WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%A5','å');     //LATIN SMALL LETTER A WITH RING ABOVE
  s:=AnsiReplaceAll(s,'%C3%A6','æ');     //LATIN SMALL LETTER AE
  s:=AnsiReplaceAll(s,'%C3%A7','ç');     //LATIN SMALL LETTER C WITH CEDILLA
  s:=AnsiReplaceAll(s,'%C3%A8','è');     //LATIN SMALL LETTER E WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%A9','é');     //LATIN SMALL LETTER E WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%AA','ê');     //LATIN SMALL LETTER E WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%AB','ë');     //LATIN SMALL LETTER E WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%AC','ì');     //LATIN SMALL LETTER I WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%AD','í');     //LATIN SMALL LETTER I WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%AE','î');     //LATIN SMALL LETTER I WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%AF','ï');     //LATIN SMALL LETTER I WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%B0','ð');     //LATIN SMALL LETTER ETH
  s:=AnsiReplaceAll(s,'%C3%B1','ñ');     //LATIN SMALL LETTER N WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%B2','ò');     //LATIN SMALL LETTER O WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%B3','ó');     //LATIN SMALL LETTER O WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%B4','ô');     //LATIN SMALL LETTER O WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%B5','õ');     //LATIN SMALL LETTER O WITH TILDE
  s:=AnsiReplaceAll(s,'%C3%B6','ö');     //LATIN SMALL LETTER O WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%B7','÷');     //DIVISION SIGN
  s:=AnsiReplaceAll(s,'%C3%B8','ø');     //LATIN SMALL LETTER O WITH STROKE
  s:=AnsiReplaceAll(s,'%C3%B9','ù');     //LATIN SMALL LETTER U WITH GRAVE
  s:=AnsiReplaceAll(s,'%C3%BA','ú');     //LATIN SMALL LETTER U WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%BB','û');     //LATIN SMALL LETTER U WITH CIRCUMFLEX
  s:=AnsiReplaceAll(s,'%C3%BC','ü');     //LATIN SMALL LETTER U WITH DIAERESIS
  s:=AnsiReplaceAll(s,'%C3%BD','ý');     //LATIN SMALL LETTER Y WITH ACUTE
  s:=AnsiReplaceAll(s,'%C3%BE','þ');     //LATIN SMALL LETTER THORN
  s:=AnsiReplaceAll(s,'%C3%BF','ÿ');     //LATIN SMALL LETTER Y WITH DIAERESIS

  result := s;
end;


//------------------------------------------------
// replace HTML4 to character
// Quelle: http://www.utf8-chartable.de/
function HTML4ToChar(s : string):string;
begin
    s:=AnsiReplaceAll(s,'&amp;','&');                       //AMPERSAND
    s:=AnsiReplaceAll(s,'&lt;','<');                        //LESS-THAN SIGN
    s:=AnsiReplaceAll(s,'&gt;','>');                        //GREATER-THAN SIGN
    s:=AnsiReplaceAll(s,'&nbsp;','');                       //NO-BREAK SPACE
    s:=AnsiReplaceAll(s,'&iexcl;','¡');                     //INVERTED EXCLAMATION MARK
    s:=AnsiReplaceAll(s,'&cent;','¢');                      //CENT SIGN
    s:=AnsiReplaceAll(s,'&pound;','£');                     //POUND SIGN
    s:=AnsiReplaceAll(s,'&curren;','¤');                    //CURRENCY SIGN
    s:=AnsiReplaceAll(s,'&yen;','¥');                       //YEN SIGN
    s:=AnsiReplaceAll(s,'&brvbar;','¦');                    //BROKEN BAR
    s:=AnsiReplaceAll(s,'&sect;','§');                      //SECTION SIGN
    s:=AnsiReplaceAll(s,'&uml;','¨');                       //DIAERESIS
    s:=AnsiReplaceAll(s,'&copy;','©');                      //COPYRIGHT SIGN
    s:=AnsiReplaceAll(s,'&ordf;','ª');                      //FEMININE ORDINAL INDICATOR
    s:=AnsiReplaceAll(s,'&laquo;','«');                     //LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    s:=AnsiReplaceAll(s,'&not;','¬');                       //NOT SIGN
    s:=AnsiReplaceAll(s,'&shy;','­');                       //SOFT HYPHEN
    s:=AnsiReplaceAll(s,'&reg;','®');                       //REGISTERED SIGN
    s:=AnsiReplaceAll(s,'&macr;','¯');                      //MACRON
    s:=AnsiReplaceAll(s,'&deg;','°');                       //DEGREE SIGN
    s:=AnsiReplaceAll(s,'&plusmn;','±');                    //PLUS-MINUS SIGN
    s:=AnsiReplaceAll(s,'&sup2;','²');                      //SUPERSCRIPT TWO
    s:=AnsiReplaceAll(s,'&sup3;','³');                      //SUPERSCRIPT THREE
    s:=AnsiReplaceAll(s,'&acute;','´');                     //ACUTE ACCENT
    s:=AnsiReplaceAll(s,'&micro;','µ');                     //MICRO SIGN
    s:=AnsiReplaceAll(s,'&para;','¶');                      //PILCROW SIGN
    s:=AnsiReplaceAll(s,'&middot;','·');                    //MIDDLE DOT
    s:=AnsiReplaceAll(s,'&cedil;','¸');                     //CEDILLA
    s:=AnsiReplaceAll(s,'&sup1;','¹');                      //SUPERSCRIPT ONE
    s:=AnsiReplaceAll(s,'&ordm;','º');                      //MASCULINE ORDINAL INDICATOR
    s:=AnsiReplaceAll(s,'&raquo;','»');                     //RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    s:=AnsiReplaceAll(s,'&frac14;','¼');                    //VULGAR FRACTION ONE QUARTER
    s:=AnsiReplaceAll(s,'&frac12;','½');                    //VULGAR FRACTION ONE HALF
    s:=AnsiReplaceAll(s,'&frac34;','¾');                    //VULGAR FRACTION THREE QUARTERS
    s:=AnsiReplaceAll(s,'&iquest;','¿');                    //INVERTED QUESTION MARK
    s:=AnsiReplaceAll(s,'&Agrave;','À');                    //LATIN CAPITAL LETTER A WITH GRAVE
    s:=AnsiReplaceAll(s,'&Aacute;','Á');                    //LATIN CAPITAL LETTER A WITH ACUTE
    s:=AnsiReplaceAll(s,'&Acirc;','Â');                     //LATIN CAPITAL LETTER A WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&Atilde;','Ã');                    //LATIN CAPITAL LETTER A WITH TILDE
    s:=AnsiReplaceAll(s,'&Auml;','Ä');                      //LATIN CAPITAL LETTER A WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&Aring;','Å');                     //LATIN CAPITAL LETTER A WITH RING ABOVE
    s:=AnsiReplaceAll(s,'&AElig;','Æ');                     //LATIN CAPITAL LETTER AE
    s:=AnsiReplaceAll(s,'&Ccedil;','Ç');                    //LATIN CAPITAL LETTER C WITH CEDILLA
    s:=AnsiReplaceAll(s,'&Egrave;','È');                    //LATIN CAPITAL LETTER E WITH GRAVE
    s:=AnsiReplaceAll(s,'&Eacute;','É');                    //LATIN CAPITAL LETTER E WITH ACUTE
    s:=AnsiReplaceAll(s,'&Ecirc;','Ê');                     //LATIN CAPITAL LETTER E WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&Euml;','Ë');                      //LATIN CAPITAL LETTER E WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&Igrave;','Ì');                    //LATIN CAPITAL LETTER I WITH GRAVE
    s:=AnsiReplaceAll(s,'&Iacute;','Í');                    //LATIN CAPITAL LETTER I WITH ACUTE
    s:=AnsiReplaceAll(s,'&Icirc;','Î');                     //LATIN CAPITAL LETTER I WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&Iuml;','Ï');                      //LATIN CAPITAL LETTER I WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&ETH;','Ð');                       //LATIN CAPITAL LETTER ETH
    s:=AnsiReplaceAll(s,'&Ntilde;','Ñ');                    //LATIN CAPITAL LETTER N WITH TILDE
    s:=AnsiReplaceAll(s,'&Ograve;','Ò');                    //LATIN CAPITAL LETTER O WITH GRAVE
    s:=AnsiReplaceAll(s,'&Oacute;','Ó');                    //LATIN CAPITAL LETTER O WITH ACUTE
    s:=AnsiReplaceAll(s,'&Ocirc;','Ô');                     //LATIN CAPITAL LETTER O WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&Otilde;','Õ');                    //LATIN CAPITAL LETTER O WITH TILDE
    s:=AnsiReplaceAll(s,'&Ouml;','Ö');                      //LATIN CAPITAL LETTER O WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&times;','×');                     //MULTIPLICATION SIGN
    s:=AnsiReplaceAll(s,'&Oslash;','Ø');                    //LATIN CAPITAL LETTER O WITH STROKE
    s:=AnsiReplaceAll(s,'&Ugrave;','Ù');                    //LATIN CAPITAL LETTER U WITH GRAVE
    s:=AnsiReplaceAll(s,'&Uacute;','Ú');                    //LATIN CAPITAL LETTER U WITH ACUTE
    s:=AnsiReplaceAll(s,'&Ucirc;','Û');                     //LATIN CAPITAL LETTER U WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&Uuml;','Ü');                      //LATIN CAPITAL LETTER U WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&Yacute;','Ý');                    //LATIN CAPITAL LETTER Y WITH ACUTE
    s:=AnsiReplaceAll(s,'&THORN;','Þ');                     //LATIN CAPITAL LETTER THORN
    s:=AnsiReplaceAll(s,'&szlig;','ß');                     //LATIN SMALL LETTER SHARP S
    s:=AnsiReplaceAll(s,'&agrave;','à');                    //LATIN SMALL LETTER A WITH GRAVE
    s:=AnsiReplaceAll(s,'&aacute;','á');                    //LATIN SMALL LETTER A WITH ACUTE
    s:=AnsiReplaceAll(s,'&acirc;','â');                     //LATIN SMALL LETTER A WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&atilde;','ã');                    //LATIN SMALL LETTER A WITH TILDE
    s:=AnsiReplaceAll(s,'&auml;','ä');                      //LATIN SMALL LETTER A WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&aring;','å');                     //LATIN SMALL LETTER A WITH RING ABOVE
    s:=AnsiReplaceAll(s,'&aelig;','æ');                     //LATIN SMALL LETTER AE
    s:=AnsiReplaceAll(s,'&ccedil;','ç');                    //LATIN SMALL LETTER C WITH CEDILLA
    s:=AnsiReplaceAll(s,'&egrave;','è');                    //LATIN SMALL LETTER E WITH GRAVE
    s:=AnsiReplaceAll(s,'&eacute;','é');                    //LATIN SMALL LETTER E WITH ACUTE
    s:=AnsiReplaceAll(s,'&ecirc;','ê');                     //LATIN SMALL LETTER E WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&euml;','ë');                      //LATIN SMALL LETTER E WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&igrave;','ì');                    //LATIN SMALL LETTER I WITH GRAVE
    s:=AnsiReplaceAll(s,'&iacute;','í');                    //LATIN SMALL LETTER I WITH ACUTE
    s:=AnsiReplaceAll(s,'&icirc;','î');                     //LATIN SMALL LETTER I WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&iuml;','ï');                      //LATIN SMALL LETTER I WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&eth;','ð');                       //LATIN SMALL LETTER ETH
    s:=AnsiReplaceAll(s,'&ntilde;','ñ');                    //LATIN SMALL LETTER N WITH TILDE
    s:=AnsiReplaceAll(s,'&ograve;','ò');                    //LATIN SMALL LETTER O WITH GRAVE
    s:=AnsiReplaceAll(s,'&oacute;','ó');                    //LATIN SMALL LETTER O WITH ACUTE
    s:=AnsiReplaceAll(s,'&ocirc;','ô');                     //LATIN SMALL LETTER O WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&otilde;','õ');                    //LATIN SMALL LETTER O WITH TILDE
    s:=AnsiReplaceAll(s,'&ouml;','ö');                      //LATIN SMALL LETTER O WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&divide;','÷');                    //DIVISION SIGN
    s:=AnsiReplaceAll(s,'&oslash;','ø');                    //LATIN SMALL LETTER O WITH STROKE
    s:=AnsiReplaceAll(s,'&ugrave;','ù');                    //LATIN SMALL LETTER U WITH GRAVE
    s:=AnsiReplaceAll(s,'&uacute;','ú');                    //LATIN SMALL LETTER U WITH ACUTE
    s:=AnsiReplaceAll(s,'&ucirc;','û');                     //LATIN SMALL LETTER U WITH CIRCUMFLEX
    s:=AnsiReplaceAll(s,'&uuml;','ü');                      //LATIN SMALL LETTER U WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&yacute;','ý');                    //LATIN SMALL LETTER Y WITH ACUTE
    s:=AnsiReplaceAll(s,'&thorn;','þ');                     //LATIN SMALL LETTER THORN
    s:=AnsiReplaceAll(s,'&yuml;','ÿ');                      //LATIN SMALL LETTER Y WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&OElig;','Œ');                     //LATIN CAPITAL LIGATURE OE
    s:=AnsiReplaceAll(s,'&oelig;','œ');                     //LATIN SMALL LIGATURE OE
    s:=AnsiReplaceAll(s,'&Scaron;','Š');                    //LATIN CAPITAL LETTER S WITH CARON
    s:=AnsiReplaceAll(s,'&scaron;','š');                    //LATIN SMALL LETTER S WITH CARON
    s:=AnsiReplaceAll(s,'&Yuml;','Ÿ');                      //LATIN CAPITAL LETTER Y WITH DIAERESIS
    s:=AnsiReplaceAll(s,'&fnof;','ƒ');                      //LATIN SMALL LETTER F WITH HOOK
    s:=AnsiReplaceAll(s,'&circ;','ˆ');                      //MODIFIER LETTER CIRCUMFLEX ACCENT
    s:=AnsiReplaceAll(s,'&tilde;','˜');                     //SMALL TILDE

  result := s;
end;




//-------------------------------------------------------------------------------------------
// manche Bücher sind nicht als XML verlinkt, sondern nach alter Art ([...]gutenberg.de/buch/1234/12)
// dabei geben die Ziffern nach dem letzten Slash das Kapitel an. Sind also nicht nur alt, sondern auch noch falsch verlinkt
// wird hier repariert
function ChangeOldLink(S :String):String;

begin
     if (pos('.xml',S)>0) then result := S
     else begin
          while (isNumeric(S[length(S)])) do S := Copy(S,1,length(S)-1);
          result := S + '1';
     end;
end;
//-------------------------------------------------------------------------------------------
function DoFilenamecomp(S :String):String;
begin
         s := AnsiReplaceAll(s,'<','');
         s := AnsiReplaceAll(s,'>','');
         s := AnsiReplaceAll(s,':',' ');
         s := AnsiReplaceAll(s,'"','');
         s := AnsiReplaceAll(s,'\','');
         s := AnsiReplaceAll(s,'/','');
         s := AnsiReplaceAll(s,'|','');
         s := AnsiReplaceAll(s,'*','');
         s := AnsiReplaceAll(s,'?','');
         s := AnsiReplaceAll(s,'[','');
         s := AnsiReplaceAll(s,']','');
         s := AnsiReplaceAll(s,'=','');
         s := AnsiReplaceAll(s,'%','');
         s := AnsiReplaceAll(s,'$','');
         s := AnsiReplaceAll(s,'+','');
         s := AnsiReplaceAll(s,',','');
         s := AnsiReplaceAll(s,';','');
         result := s;
end;
//-------------------------------------------------------------------------------------------
function ClearTitel(S :String):String;
begin
      S:= ClearSpezChar(S);
      if (Pos('Als Buch erhaeltlich fuer',S)>0) then  S:= Copy(S,1, Pos('Als Buch erhaeltlich fuer',S)-1);
      if (Pos('<',S)>0) then  S:= Copy(S,1, Pos('<',S)-1);

      if length(S) > 100 then S:= Copy(S,1, 100);
      Result:=S;
end;
//-------------------------------------------------------------------------------------------
function ClearUrl(S :String):String;
begin
      S:= Trim(S);
      if (Pos('http://',S)>1) then  begin
         S:= Copy(S,Pos('http://',S),length(S));
      end;
      if (Pos('http://',S)=0) then begin
         S:= 'http://gutenberg.spiegel.de/' + S;
      end;
      Result:=S;
end;
//-------------------------------------------------------------------------------------------
function ClearHeading(S :String):String;
begin
    S:=AnsiReplaceAll(S,'<h1>','');
    S:=AnsiReplaceAll(S,'<h2>','');
    S:=AnsiReplaceAll(S,'<h3>','');
    S:=AnsiReplaceAll(S,'<h4>','');
    S:=AnsiReplaceAll(S,'</h1>','');
    S:=AnsiReplaceAll(S,'</h2>','');
    S:=AnsiReplaceAll(S,'</h3>','');
    S:=AnsiReplaceAll(S,'</h4>','');
    S:=AnsiReplaceAll(S,'<i>','');
    S:=AnsiReplaceAll(S,'</i>','');

    S:=AnsiReplaceAll(S,'<br />','');
    S:=AnsiReplaceAll(S,'<br/>','');

    S:= Trim(S);
    Result:=S;
end;

//-------------------------------------------------------------------------------------------
//  Clear Characters
function ClearSpezChar(S : string):string;
begin
  S:=AnsiReplaceAll(S,'/','');
  S:=AnsiReplaceAll(S,'?','');
  result := S;
end;
//-------------------------------------------------------------------------------------------
// später aus Datei einlesen
function inAusnahme(S : string):boolean;
begin
     result :=  ((pos('kasphaus.xml',S)<>0) or (pos('poettage.xml',S)<>0) or (pos('/colerus/',S)<>0) or (pos('/haegele/',S)<>0) or (pos('/herzl/',S)<>0));
end;

//-------------------------------------------------------------------------------------------
function isValidItem (S : string):boolean;
begin
  result := (Pos('<a href="',S)>0);
  result := result and (Pos('"http://www.tredition.de',S)=0);
  result := result and (Pos('"http://www.publish-books.de',S)=0);
  result := result and (Pos('"http://www.amazon.de',S)=0);
  result := result and (Pos('esperrt',S)=0);
  result := result and (Pos('erhältlich',S)=0);
  result := result and (Pos('Leseprobe',S)=0);
  result := result and (Pos('.pdf">',S)=0);
  result := result and (Pos('00/00/00',S)=0);
  result := result and (Pos('bersetzungen von',S)=0);
  result := result and ((Pos('../',S)<>0) or (Pos('http://gutenberg.spiegel.de/buch/',S)<>0) or (inAusnahme(S)));
end;
(*function GetKapCount(sFile:string):integer;
var slT : TStringList;
    iC,i  : integer;
    sT  : string;
begin
     Result := 1;
     sT := '';
     iC := 0;
     slT := TStringList.Create;

     if (slT <> nil) then begin
        slT.LoadFromFile(sFile);
        repeat
              sT := slT.Strings[iC];
              inc(iC);
        until ((iC>=slT.Count) or (Pos('<option value="1" selected="selected"',sT)>0));
        if (iC<slT.Count) then begin
           //sT:=AnsiReplaceAll(sT,'"',#13);
           sT:=AnsiReplaceAll(sT,'<option value="',#13);
           slT.Text:=sT;
           (*if ((slT.Count > 1) and (isNumeric(slT.Strings[slT.Count-2]))) then begin
              Result := StrToInt(slT.Strings[slT.Count-2]);
           end; *)
           if (slT.Count > 0) then begin
              sT := '';
              iC := slT.Count-1;
              while ((iC >= 0) and (length(slT.Strings[iC])<1)) do dec(iC);
              if (iC > 0) then begin
                 i := Pos('"',slT.Strings[iC]);
                 if (i>0) then sT := Copy(slT.Strings[iC],0,i-1);
                 if (isNumeric(sT)) then Result := StrToInt(sT);
              end;
           end;
        end;
     end;
     slT.Free;
end;   *)
//-------------------------------------------------------------------------------------------
function GetKapCount(sFile:string):integer;
var slT : TStringList;
    iC,i,j  : integer;
    sT  : string;
begin
     Result := 1;
     sT := '';
     iC := 0;
     slT := TStringList.Create;
     if (slT <> nil) then begin
        slT.LoadFromFile(sFile);
        repeat
              sT := slT.Strings[iC];
              inc(iC);
        until ((iC>=slT.Count) or (Pos('<li class="active"><a href="',sT)>0));
        if (iC<slT.Count) then begin
           sT:=AnsiReplaceAll(sT,'<li><a href="',#13);
           sT:=AnsiReplaceAll(sT,'</ul>','');
           sT:=AnsiReplaceAll(sT,'</li>','');
           slT.Text:=sT;
           if (slT.Count > 0) then begin
              sT := '';
              iC := slT.Count-1;
              while ((iC >= 0) and (length(slT.Strings[iC])<1)) do dec(iC);
              if (iC > 0) then begin
                 i := Pos('"',slT.Strings[iC]);
                 if (i>0) then begin
                    j:=1;
                    while ((length(slT.Strings[iC])>(i-j)) and (slT.Strings[iC][i-j] <> '/')) do inc(j);
                    if (j<i) then begin
                       sT := Copy(slT.Strings[iC],i-j+1,j-1);
                       if (isNumeric(sT)) then Result := StrToInt(sT);
                       sStripAddress := Copy(slT.Strings[iC],1,i-j);
                    end;
                 end;
              end;
           end;
        end;
     end;
     slT.Free;
end;
//-------------------------------------------------------------------------------------------

function GetAdresse(sFile:string):string;
(*var slT : TStringList;
    iC  : integer;
    sT  : string;   *)
begin
Result := 'http://gutenberg.spiegel.de' +  sStripAddress;
(*     Result := '';
     sT := '';
     iC := 0;
     slT := TStringList.Create;
     if (slT <> nil) then begin
        slT.LoadFromFile(sFile);
        repeat
              sT := slT.Strings[iC];
              inc(iC);
        until ((iC>=slT.Count) or (Pos('<select id="chapters" onchange="self.location.href=',sT)>0));
        if (iC<slT.Count) then begin
           //sT:=AnsiReplaceAll(sT,'"',#13);
           // Example:
           //  <div>Navigation: <select id="chapters" onchange="self.location.href='/buch/2808/'+this.value;">
           sT:=AnsiReplaceAll(sT,'<div>Navigation: <select id="chapters" onchange="self.location.href=','');
           sT:=AnsiReplaceAll(sT,'+this.value;">','');
           sT := Copy(sT, 2, length(sT)-2);
           Result := 'http://gutenberg.spiegel.de' + sT;

           //slT.Text:=sT;
           //(*if ((slT.Count > 1) and (isNumeric(slT.Strings[slT.Count-2]))) then begin
           //   Result := StrToInt(slT.Strings[slT.Count-2]);
           //end; *)
           //if (slT.Count > 0) then begin
           //   sT := '';
           //   iC := slT.Count-1;
           //   while ((iC >= 0) and (length(slT.Strings[iC])<1)) do dec(iC);
           //   if (iC > 0) then begin
           //      i := Pos('"',slT.Strings[iC]);
           //      if (i>0) then sT := Copy(slT.Strings[iC],0,i-1);
           //      if (isNumeric(sT)) then Result := sT;
           //   end;
           //end;
        end;
     end;
     slT.Free;  *)
end;

//-------------------------------------------------------------------------------------------
// Liste aller Autoren von gutenberg.spiegel.de  oder zeno.org
// Aufbau:
//        Url*Name
procedure CreateAuthorList(sSrcDir, sAutorfile: string; sSource: string);
var slIn, slOut : TStringList;
    sItem       : string;
    j           : integer;
    sPath, sAkt : string;
    bCopy       : boolean;

begin
     sPath := sSrcDir + 'temp'+PathDelim;
     slOut := TStringList.Create();
     slIn  := TStringList.Create();

     if (sSource = 'Gutenberg') then sAkt := sPath + 'Autor';
     if (sSource = 'Zeno')      then sAkt := sPath + 'Inhaltsverzeichnis';

     if (FileExists(sAkt)) then begin
        slIn.Clear;
        slIn.LoadFromFile(sAkt);
        bCopy := false;
        for j:=0 to slIn.Count-1 do begin
            sItem := slIn.Strings[j];
            //-----------------------------------------------------------------
            if sSource = 'Gutenberg' then begin
                if ((bCopy) and (Pos('<div id="',sItem)>0)) then begin
                   bCopy := false;
                end;
                if (bCopy) then begin
                   //Alle Autoren in einem String!!!
                   sItem:= ClearTags(sItem);
                   split ('#', sItem, slOut);

                   //for i:=0to slOut.Count-1 do begin
                   //    sItem:= slOut.Strings[i];
                   //    if ((Pos('http://gutenberg.spiegel.de/autor/12',sItem)>0) or (Pos('http://gutenberg.spiegel.de/autor/1012',sItem)>0) ) then begin
                   //       bCopy:=true;
                   //     end;
                   //end;

                end;
                if (Pos('<h2>Alle Autoren',sItem)>0) then begin
                  bCopy := true;
                end;
            end; // 'Gutenberg'
            //-----------------------------------------------------------------
            if sSource = 'Zeno' then begin
                // Alle Autoreneinträge im Inhaltsverzeichnis beginnen mit diesem Postfix:
                if (Pos('<li><b><a href="/Literatur',sItem)>0) then begin
                  sItem := ClearTags(sItem);
                  // Format:  Url*Name
                  slOut.Add(sItem);
                end;
            end; // 'Zeno'
            //-----------------------------------------------------------------
        end;
     end;

     slOut.SaveToFile(sPath + sAutorfile);
     //slOut.SaveToFile(sOutputDir + sAutorfile);
     slOut.Free;
     slIn.Free;
end;
//-------------------------------------------------------------------------------------------
procedure DeleteFiles(Name: string);
var
   srec: TSearchRec;
begin
if FindFirst(Name, faAnyFile, srec) = 0 then
   try
      repeat
            DeleteFile(srec.Name);
      until FindNext(srec) <> 0;
   finally
          FindCLose(srec);
   end;
end;



//-------------------------------------------------------------------------------------------
procedure ClearDir(sDir: string);
begin
     if (DirectoryExists(sDir)) then DeleteDirectory(sDir, false);
end;

//-------------------------------------------------------------------------------------------
procedure MakeDir(sDir: string);
begin
//###
// UTF8 konforme Verzeichnisanlage verwenden
//    ForceDirectories(sDir);
    ForceDirectory(sDir);
//###
end;
//-------------------------------------------------------------------------------------------
procedure CopyAll(sSrcDir, sDstDir: string);
var sr : TSearchRec;
    iAttributes : integer;
begin
     MakeDir(sDstDir);
     iAttributes := faAnyFile;
     if (FindFirst(sSrcDir+PathDelim+'*.*', iAttributes, sr) = 0) then begin
        repeat
	      if ((sr.Attr and iAttributes) = sr.Attr) then begin
                     CopyOne(sSrcDir + PathDelim + sr.Name, sDstDir + PathDelim + sr.Name);
              end;
	until (FindNext(sr) <> 0);
	FindClose(sr);
     end;
end;
//-------------------------------------------------------------------------------------------
procedure CopyOne(sSrc, sDst: string);
begin
     if (not FileExists(sDst)) then CopyFile(pchar(sSrc),pchar(sDst));
end;


end.

